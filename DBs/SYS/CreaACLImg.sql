BEGIN
DBMS_NETWORK_ACL_ADMIN.DROP_ACL(
      acl => 'tmdb.xml');
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(acl         => 'tmdb.xml',
                                    description => 'tmdb ACL',
                                    principal   => 'CB',
                                    is_grant    => true,
                                    privilege   => 'connect');
 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl       => 'tmdb.xml',
                                       principal => 'CB',
                                       is_grant  => true,
                                       privilege => 'resolve');
 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(acl  => 'tmdb.xml',
                                    host => 'image.tmdb.org');
END;
/
COMMIT;
