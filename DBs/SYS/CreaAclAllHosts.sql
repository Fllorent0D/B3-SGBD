BEGIN
DBMS_NETWORK_ACL_ADMIN.DROP_ACL(
      acl => 'all.xml');
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(acl         => 'all.xml',
                                    description => 'all ACL',
                                    principal   => 'CC',
                                    is_grant    => true,
                                    privilege   => 'connect');
 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl       => 'all.xml',
                                       principal => 'CC',
                                       is_grant  => true,
                                       privilege => 'resolve');
 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(acl  => 'all.xml',
                                    host => '*');
END;
/
COMMIT;