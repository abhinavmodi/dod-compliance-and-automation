control 'UBTU-22-654115' do
  title 'Ubuntu 22.04 LTS must generate audit records for successful/unsuccessful uses of the umount command.'
  desc 'Without generating audit records that are specific to the security and mission needs of the organization, it would be difficult to establish, correlate, and investigate the events relating to an incident or identify those responsible for one.

Audit records can be generated from various components within the information system (e.g., module or policy filter).'
  desc 'check', 'Verify if Ubuntu 22.04 LTS generates audit records upon successful/unsuccessful attempts to use the "umount" command by using the following command:

     $ sudo auditctl -l | grep /usr/bin/umount
     -a always,exit -S all -F path=/usr/bin/umount -F perm=x -F auid>=1000 -F auid!=-1 -F key=privileged-umount

If the command does not return lines that match the example or the lines are commented out, this is a finding.

Note: The "key=" value is arbitrary and can be different from the example output above.'
  desc 'fix', 'Configure the audit system to generate an audit event for any successful/unsuccessful use of the "umount" command.

Add or modify the following line in the "/etc/audit/rules.d/stig.rules" file:

-a always,exit -F path=/usr/bin/umount -F perm=x -F auid>=1000 -F auid!=unset -k privileged-umount

To reload the rules file, issue the following command:

     $ sudo augenrules --load

Note: The "-k <keyname>" at the end of the line gives the rule a unique meaning to help during an audit investigation. The <keyname> does not need to match the example above.'
  impact 0.5
  ref 'DPMS Target Canonical Ubuntu 22.04 LTS'
  tag check_id: 'C-64354r953686_chk'
  tag severity: 'medium'
  tag gid: 'V-260625'
  tag rid: 'SV-260625r958446_rule'
  tag stig_id: 'UBTU-22-654115'
  tag gtitle: 'SRG-OS-000064-GPOS-00033'
  tag fix_id: 'F-64262r953687_fix'
  tag 'documentable'
  tag cci: ['CCI-000172']
  tag nist: ['AU-12 c']

  @audit_file = '/usr/bin/umount'

  audit_lines_exist = !auditd.lines.index { |line| line.include?(@audit_file) }.nil?
  if audit_lines_exist
    describe auditd.file(@audit_file) do
      its('permissions') { should_not cmp [] }
      its('action') { should_not include 'never' }
    end

    @perms = auditd.file(@audit_file).permissions

    @perms.each do |perm|
      describe perm do
        it { should include 'x' }
      end
    end
  else
    describe("Audit line(s) for #{@audit_file} exist") do
      subject { audit_lines_exist }
      it { should be true }
    end
  end
end
