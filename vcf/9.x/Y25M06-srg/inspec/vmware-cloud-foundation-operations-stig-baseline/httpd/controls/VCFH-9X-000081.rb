control 'VCFH-9X-000081' do
  title 'The VMware Cloud Foundation Operations Apache HTTP service must prohibit or restrict the use of nonsecure or unnecessary ports, protocols, modules, and/or services.'
  desc  "
    Web servers provide numerous processes, features, and functionalities that utilize TCP/IP ports. Some of these processes may be deemed unnecessary or too unsecure to run on a production system.

    The web server must provide the capability to disable or deactivate network-related services that are deemed to be non-essential to the server mission, are too unsecure, or are prohibited by the PPSM CAL and vulnerability assessments.
  "
  desc  'rationale', ''
  desc  'check', "
    Verify the service is only listening on authorized ports and interfaces.

    At the command prompt, run the following:

    # grep -i \"Listen\" /etc/httpd/conf/httpd.conf /etc/httpd/listen.conf /usr/lib/vmware-vcopssuite/utilities/conf/vcops-apache.conf

    Example output:

    Listen 80
    Listen <IP Address>:443
    Listen 127.0.0.1:443

    If any \"Listen\" directives are configured other than shown in the example output, this is a finding.
  "
  desc 'fix', "
    Navigate to and open:

    /etc/httpd/listen.conf

    Note: If the offending configuration was found in a different file edit that file instead.

    Remove any unknown \"Listen\" directives and/or update the existing directives as shown below.

    Listen 80
    Listen <IP Address>:443
    Listen 127.0.0.1:443

    Note: Replace <IP Address> with the configured IP Address of the server.

    Restart the service by running the following command:

    # systemctl restart httpd
  "
  impact 0.5
  tag severity: 'medium'
  tag gtitle: 'SRG-APP-000383-WSR-000175'
  tag gid: 'V-VCFH-9X-000081'
  tag rid: 'SV-VCFH-9X-000081'
  tag stig_id: 'VCFH-9X-000081'
  tag cci: ['CCI-001762']
  tag nist: ['CM-7 (1) (b)']

  conf = input('apache_httpd_conf_file')

  # Make sure the conf file exists so the tests do not pass with false positives
  describe file(conf) do
    it { should exist }
  end

  apache_allowed_listeners = input('apache_allowed_listeners')
  # Add appliance ip to the array
  applianceip = command("ip -br addr show eth0 |&awk '{print $3}' |&cut -d'/' -f1").stdout.strip
  apache_allowed_listeners.push("#{applianceip}:443")

  # Test to see which Listen directives are enabled
  listeners = apache_conf_custom(conf).Listen
  if !listeners.nil?
    listeners.each do |listen|
      describe "Listen: #{listen}" do
        subject { listen }
        it { should be_in apache_allowed_listeners }
      end
    end
  else
    describe 'Listen directive' do
      subject { listeners }
      it { should_not be_nil }
    end
  end
end
