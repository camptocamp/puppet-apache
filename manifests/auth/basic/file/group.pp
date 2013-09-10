define apache::auth::basic::file::group (
  $ensure="present",
  $authname=false,
  $vhost,
  $location="/",
  $authUserFile=false,
  $authGroupFile=false,
  $groups){

  validate_string($groups)

  $wwwroot = $apache::root
  validate_absolute_path($wwwroot)

  $fname = regsubst($name, "\s", "_", "G")

  include apache::params

  if defined(Apache::Module["authn_file"]) {} else {
    apache::module {"authn_file": }
  }

  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "${wwwroot}/${vhost}/private/htpasswd"
  }

  if $authGroupFile {
    $_authGroupFile = $authGroupFile
  } else {
    $_authGroupFile = "${wwwroot}/${vhost}/private/htgroup"
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  file { "${wwwroot}/${vhost}/conf/auth-basic-file-group-${fname}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-file-group.erb"),
    seltype => $::operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }

}
