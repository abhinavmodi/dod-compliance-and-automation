control 'VCFM-9X-000063' do
  title 'The VMware Cloud Foundation vCenter VAMI Lighttpd service must interpret and normalize ambiguous HTTP requests.'
  desc  "
    Request smuggling attacks involve placing both the Content-Length header and the Transfer-Encoding header into a single HTTP/1 request and manipulating it so that web servers (i.e., back-end, front-end, load balancers) process the request differently. There are a number of variants of this type of attack with different names. However, all variants are addressed by configuring the front-end server to exclusively use HTTP/2 when communicating with other web servers. Specific instances of this vulnerability can be resolved by reconfiguring the front-end server to normalize ambiguous requests before routing them onward. However, if the request cannot be made unambiguous or normalized, configure both the front-end and back-end servers to reject the message and close the connection.

    It is important to not assume requests do not have a body. For all web servers, examine requests that report message body length as zero in the HTTP header and drop the request.

    For load balancing or reverse proxying implementation:
    -The front-end web server must interpret and forward HTTP requests, such that the back-end server receives a consistent interpretation of the request, or terminate the TCP connection.
    -The back-end web server must drop ambiguous requests that cannot be normalized and terminate the TCP connection.
  "
  desc  'rationale', ''
  desc  'check', "
    At the command prompt, run the following:

    # /usr/sbin/lighttpd -p -f /etc/lighttpd/lighttpd.conf 2>/dev/null|awk '/server\\.http-parseopts/,/\\)/'

    Example output:

    server.http-parseopts = (
    \t\"header-strict\"            => \"enable\",
    \t\"host-strict\"              => \"enable\",
    \t\"host-normalize\"           => \"enable\",
    \t\"url-normalize\"            => \"enable\",
    \t\"url-normalize-unreserved\" => \"enable\",
    \t\"url-normalize-required\"   => \"enable\",
    \t\"url-ctrls-reject\"         => \"enable\",
    \t\"url-path-2f-decode\"       => \"enable\",
    \t\"url-path-dotseg-remove\"   => \"enable\",
    \t\"url-query-20-plus\"        => \"enable\"
     )

    If the command returns no output, this is NOT a finding.

    If the \"server.http-parseopts\" option is configured and all parameter values are not \"enable\", this is a finding.

    Note: If not specified, all \"server.http-parseopts\" parameters are set to \"enable\" by default.

    Note: The command must be run from a bash shell and not from a shell generated by the \"appliance shell\". Use the \"chsh\" command to change the shell for the account to \"/bin/bash\". Refer to KB Article 2100508 for more details:

    https://knowledge.broadcom.com/external/article?legacyId=2100508
  "
  desc 'fix', "
    Navigate to and open:

    /etc/applmgmt/appliance/applmgmt-lighttpd.conf

    Delete the \"server.http-parseopts\" section.

    Note: The line may be in an included config and not in the parent config itself.

    Restart the service with the following command:

    # systemctl restart lighttpd
  "
  impact 0.5
  tag severity: 'medium'
  tag gtitle: 'SRG-APP-000251-WSR-000194'
  tag satisfies: ['SRG-APP-000251-WSR-000195']
  tag gid: 'V-VCFM-9X-000063'
  tag rid: 'SV-VCFM-9X-000063'
  tag stig_id: 'VCFM-9X-000063'
  tag cci: ['CCI-001310']
  tag nist: ['SI-10']

  httpparseopts = command("#{input('lighttpdBin')} -p -f #{input('lighttpdConf')} 2>/dev/null|awk '/server\\.http-parseopts/,/\\)/'").stdout.strip
  if !httpparseopts.empty?
    results = httpparseopts.scan(/"(.*?)"\s*=>\s*"(.*?)"/).to_h
    results.each do |k, v|
      describe "HTTP Parse Option: #{k}" do
        subject { v }
        it { should cmp 'enable' }
      end
    end
  else
    describe 'Configuration server.http-parseopts not present and' do
      subject { httpparseopts }
      it { should be_empty }
    end
  end
end
