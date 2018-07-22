--1.
create or replace   function Valid_IP (IP_ADDRESS in varchar2)  
							   return number 
							   IS 
fst number; 
sec number; 
thd number; 
fth number;						    
  BEGIN 
	 
	 
    if (length(IP_ADDRESS) - length(replace(IP_ADDRESS,'.')))!=3 
	then return 0; 
	else 
		fst:= to_number(substr(IP_ADDRESS, 1, instr(IP_ADDRESS,'.')-1)); 
		sec:= to_number(substr(IP_ADDRESS, instr(IP_ADDRESS,'.')+1, instr(IP_ADDRESS,'.',1,2)-instr(IP_ADDRESS,'.'))); 
		thd:= to_number(substr(IP_ADDRESS, instr(IP_ADDRESS,'.',1,2)+1, instr(IP_ADDRESS,'.',1,3)-instr(IP_ADDRESS,'.',1,2))); 
		fth:= to_number(substr(IP_ADDRESS, instr(IP_ADDRESS,'.',1,3)+1)); 		if fst>255 or sec>255 or thd>255 or fth>255 
		then return 0; 
		else return 1; 
		end if; 
		end if; 
exception 
when others then 
raise_application_error (-20026, 'INVALID IP ADRESS' ); 
 
  END;
  /

create or replace PROCEDURE saveCOMMUTATOR(
                        pID_COMMUTATOR in incb_commutator.id_commutator%type,
                         pIP_ADDRESS       IN incb_commutator.IP_ADDRESS%TYPE,
                         pID_COMMUTATOR_TYPE IN incb_commutator.ID_COMMUTATOR_TYPE%TYPE default null,
                         pV_DESCRIPTION IN incb_commutator.V_DESCRIPTION%TYPE default null,
							pB_DELETED IN incb_commutator.B_DELETED%TYPE default null,
						 pV_MAC_ADDRESS    IN incb_commutator.V_MAC_ADDRESS%TYPE,
                          pV_COMMUNITY_READ IN incb_commutator.V_COMMUNITY_READ%TYPE,
						  pV_COMMUNITY_WRITE IN incb_commutator.V_COMMUNITY_WRITE%TYPE,
						  pREMOTE_ID IN incb_commutator.REMOTE_ID%TYPE,
						  	pB_NEED_CONVERT_HEX IN incb_commutator.B_NEED_CONVERT_HEX%TYPE default 0,
							pREMOTE_ID_HEX IN incb_commutator.REMOTE_ID_HEX%TYPE default null,
							pACTION in number) IS
ip_ad NUMBER;
V_MAC NUMBER;
existing_adress exception;
input_hex exception;
bad_ip exception;
begin

if pB_NEED_CONVERT_HEX=1 and pREMOTE_ID_HEX is null and pACTION!=1
then raise input_hex;
elsif Valid_IP(pIP_ADDRESS) = 0 and pACTION!=1
then raise bad_ip;
end if; -- проверка на обязательность hex

	
select count(1) 
into ip_ad
from  incb_commutator C
WHERE B_DELETED=0
AND C.IP_ADDRESS=pIP_ADDRESS; --уникальность ip

select count(1) 
into V_MAC
from  incb_commutator C
WHERE B_DELETED=0
AND C.V_MAC_ADDRESS=pV_MAC_ADDRESS; --уникальность mac

  CASE
    WHEN pACTION = 1 THEN
      DELETE FROM incb_commutator WHERE IP_ADDRESS = pIP_ADDRESS and V_MAC_ADDRESS=pV_MAC_ADDRESS;
    WHEN pACTION = 2 AND IP_AD=0 AND V_MAC=0 THEN
		
      INSERT INTO incb_commutator
        (ID_COMMUTATOR, IP_ADDRESS, ID_COMMUTATOR_TYPE, V_DESCRIPTION, B_DELETED, V_MAC_ADDRESS, V_COMMUNITY_READ, V_COMMUNITY_WRITE, REMOTE_ID, B_NEED_CONVERT_HEX, REMOTE_ID_HEX)
      VALUES
        (s_incb_commutator.nextval, pIP_ADDRESS, pID_COMMUTATOR_TYPE, pV_DESCRIPTION, pB_DELETED, pV_MAC_ADDRESS, pV_COMMUNITY_READ, pV_COMMUNITY_WRITE, pREMOTE_ID, pB_NEED_CONVERT_HEX, pREMOTE_ID_HEX);
	WHEN pACTION = 2 AND (IP_AD!=0 OR V_MAC!=0) THEN
		raise existing_adress;	
    WHEN pACTION = 3 THEN
      UPDATE incb_commutator
         SET V_COMMUNITY_READ=pV_COMMUNITY_READ, V_COMMUNITY_WRITE = pV_COMMUNITY_WRITE, REMOTE_ID=pREMOTE_ID, 
		 ID_COMMUTATOR_TYPE=pID_COMMUTATOR_TYPE, V_DESCRIPTION=pV_DESCRIPTION, B_DELETED=pB_DELETED
       WHERE IP_ADDRESS = pIP_ADDRESS and V_MAC_ADDRESS=pV_MAC_ADDRESS;
  END CASE;
EXCEPTION
	WHEN no_data_found THEN
   raise_application_error (-20022,'UNKNOWN ADRESS');
   WHEN existing_adress THEN
    raise_application_error(-20020, 'EXISTING ADRESS' );
    WHEN input_hex THEN  
		raise_application_error (-20021, 'input REMOTE_ID_HEX' );
	WHEN bad_ip THEN  
		raise_application_error (-20026, 'INVALID IP ADRESS' );

  WHEN OTHERS THEN
    raise_application_error(-20023,
                            'OTHERS');
END;
/

create or replace   PROCEDURE getCOMMUTATOR(dwr OUT sys_refcursor,
                               pID_COMMUTATOR in incb_commutator.id_commutator%type default null) IS
  BEGIN
  
    OPEN dwr FOR
      select ic.IP_ADDRESS, ic.V_MAC_ADDRESS, ict.V_VENDOR, ict.V_MODEL, 
			case 
			when B_NEED_CONVERT_HEX=1
			then ic.REMOTE_ID_HEX
			else ic.REMOTE_ID
				end 
				from incb_commutator ic
		join incb_commutator_type ict
		on ict.ID_COMMUTATOR_TYPE=ic.ID_COMMUTATOR_TYPE
		and ict.b_deleted=0
			
		where ic.b_deleted=0 and ( pID_COMMUTATOR is null or ic.ID_COMMUTATOR=pID_COMMUTATOR );
		

  END;
  /
  declare 
  u sys_refcursor;
  begin
saveCOMMUTATOR(1,'128.118.5.56',2001,'description',0,'51:96:4','1','1','32',1,'yuegf', 2);
saveCOMMUTATOR(1,'128.178.5.56',2002,'description',0,'61:91:4','1','1','fg',0,null, 2);
saveCOMMUTATOR(1,'128.188.5.56',2003,'description',0,'561:46:4','1','1','45f',1,0, 2);
saveCOMMUTATOR(1,'128.118.5.56',2001,'nodescriptionatall',0,'51:96:4','1','1','44f',1,'yuegf', 3);
saveCOMMUTATOR(1,'128.188.5.56',2003,'description',0,'561:96:4','1','1','45f',1,0, 1);
getCOMMUTATOR(u,2001);
end;
/
select * from incb_commutator
/

--2.
create or replace function check_access_comm(pIP_ADDRESS       IN incb_commutator.IP_ADDRESS%TYPE,
											V_COMMUNITY IN incb_commutator.V_COMMUNITY_WRITE%TYPE,
											B_MODE_WRITE in number)
return  number IS 
                     

ACCESSS varchar2(255);               
  BEGIN 
  
  select case B_MODE_WRITE
  when 1
  then ic.V_COMMUNITY_WRITE
  when 0
  then ic.V_COMMUNITY_read
  end
  into ACCESSS
  from incb_commutator ic
  where b_deleted=0
  and ic.ip_address=pIP_ADDRESS;
  
 
                          
  if ACCESSS=V_COMMUNITY
  then return 1;
  else return 0;
  end if;
  
   EXCEPTION 
	WHEN no_data_found THEN 
   raise_application_error (-20025, 'NO SUCH AN ADRESS' ); 
  WHEN OTHERS THEN 
    raise_application_error(-20020, 'Какая-то ошибка'); 
 end;
 /
 --3.
 create or replace function get_remote_id(pID_COMMUTATOR in incb_commutator.id_commutator%type)
return  number IS 
                     
needed number;
hexx varchar2(255);
emptyy exception;
remote_id1 varchar2(255);               
  BEGIN 
  select REMOTE_ID_HEX, B_NEED_CONVERT_HEX, REMOTE_ID into hexx, needed, remote_id1 from incb_commutator
  where ID_COMMUTATOR=pID_COMMUTATOR
  and b_deleted=0;
  
  case 
  when needed=1 and hexx is null
  then raise emptyy;
  when needed=1 and hexx is not null
  then return hexx;
  when needed=0
  then return remote_id1;
 
  end case;                        
    
   EXCEPTION 
	WHEN no_data_found THEN 
   raise_application_error (-20025, 'NO SUCH AN ID' ); 
  WHEN emptyy THEN 
    raise_application_error(-20026, 'HEX NOT FOUND'); 
 end;

--4. Я пыталась, но запуталась, где нужно объявлять тип. :( 
TYPE listed IS TABLE OF number;
create or replace PROCEDURE check_and_del_data (B_FORCE_DELETE in number, coll out listed)
is

	
	COMM_rec incb_commutator%ROWTYPE;
	
coll1 listed;
coll2 listed;
coll3 listed;
coll4 listed;
begin
 
 select distinct ID_COMMUTATOR bulk collect 
 into coll1
 from incb_commutator ic
cross join  (select V_MAC_ADDRESS, count(*) as Qu from incb_commutator
	where b_deleted=0
	group by V_MAC_ADDRESS) U
	where U.V_MAC_ADDRESS=ic.V_MAC_ADDRESS
	and U.Qu>1;
	
select distinct ID_COMMUTATOR bulk collect 
 into coll1
 from incb_commutator ic
cross join  (select IP_ADDRESS, count(*) as Qu from incb_commutator
	where b_deleted=0
	group by IP_ADDRESS) U
	where U.IP_ADDRESS=ic.IP_ADDRESS
	and U.Qu>1;

select distinct ID_COMMUTATOR bulk collect
    into coll3
    from incb_commutator
	where b_deleted=0
	and B_NEED_CONVERT_HEX=1
	and REMOTE_ID_HEX is null;
	
select distinct ID_COMMUTATOR bulk collect
    into coll4
	from incb_commutator
	where Valid_IP(IP_ADDRESS) = 0
		and b_deleted=0;
	coll:=coll1 MULTISET UNION DISTINCT coll2 MULTISET UNION DISTINCT coll3 MULTISET UNION DISTINCT coll4;

if B_FORCE_DELETE = 1
then
for i in coll.first .. coll.last loop
SELECT * INTO COMM_rec FROM
incb_commutator
WHERE B_DELETED=0
AND ID_COMMUTATOR=COLL(i);
			  saveCOMMUTATOR(comm_rec.ID_COMMUTATOR, comm_rec.IP_ADDRESS, comm_rec.ID_COMMUTATOR_TYPE, comm_rec.V_DESCRIPTION, 
			  comm_rec.B_DELETED, comm_rec.V_MAC_ADDRESS, comm_rec.V_COMMUNITY_READ, comm_rec.V_COMMUNITY_WRITE, 
			  comm_rec.REMOTE_ID, comm_rec.B_NEED_CONVERT_HEX, comm_rec.REMOTE_ID_HEX, 1);
		  end loop;
end if;
		  end;

