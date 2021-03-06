class devhops::join_domain {
  # this requires the following module to be set in the Puppetfile:
  # mod 'trlinkin/domain_membership', '1.1.2'
  # 
  class { 'domain_membership':
    domain       => lookup('devhops::windows_domain::name'),
    username     => lookup('devhops::windows_domain::join_user'),
    password     => lookup('devhops::windows_domain::join_password'),
    join_options => '3',
  }
}
