--1.
CREATE OR REPLACE PROCEDURE saveSIGNERS(pV_FIO       IN scd_signers.v_fio%TYPE,
                          pID_MANAGER       IN scd_signers.id_manager%TYPE,
                          pACTION       IN NUMBER) IS
  pid_USER NUMBER;
BEGIN
  SELECT ci.id_user
    INTO pid_USER
    FROM ci_users ci
   WHERE ci.id_user = pID_MANAGER;

  CASE
    WHEN pACTION = 3 THEN
      DELETE FROM scd_signers ss WHERE id_manager = pID_MANAGER;
    WHEN pACTION = 1 THEN
      INSERT INTO scd_signers
        (v_fio, id_manager)
      VALUES
        (pV_FIO, pID_MANAGER);
    WHEN pACTION = 2 THEN
      UPDATE scd_signers
         SET v_fio = pv_fio
       WHERE  id_manager= pID_MANAGER;
  END CASE;
EXCEPTION
	WHEN no_data_found THEN
   raise_application_error (-20020,'Пользователь не найден');
  WHEN OTHERS THEN
    raise_application_error(-20020,
                            'Существующий пользователь');
END;
/
--2.
create or replace function getDecoder(id_eq in scd_equip_kits.id_equip_kits_inst%type) 
return  varchar2 IS 
                     
v_ext varchar2(255);       
v_cas varchar2(255); 
v_ret varchar2(255);
agency number;               
  BEGIN 
     

     
    SELECT c.b_agency  INTO  agency 
      FROM scd_equip_kits ek JOIN scd_contracts c ON c.id_contract_inst = ek.id_contract_inst  
    WHERE  ek.id_equip_kits_inst=id_eq and ek.dt_start <= current_timestamp AND ek.dt_stop > current_timestamp; 
     
    CASE 
    WHEN agency = 1 THEN 
     SELECT ek.V_CAS_ID INTO v_ret
          FROM SCD_EQUIP_KITS ek WHERE ek.id_equip_kits_inst=id_eq and ek.dt_start <= current_timestamp AND ek.dt_stop > current_timestamp;
    WHEN agency <> 1 THEN 
     SELECT ek.V_EXT_IDENT INTO v_ret
          FROM SCD_EQUIP_KITS ek WHERE ek.id_equip_kits_inst=id_eq and ek.dt_start <= current_timestamp AND ek.dt_stop > current_timestamp;
    
  END CASE;
return v_ret;   
EXCEPTION 
	WHEN no_data_found THEN 
   raise_application_error (-20020,'Оборудование не найдено'); 
  WHEN OTHERS THEN 
    raise_application_error(-20020, 'Какая-то ошибка'); 
                            
END; 
/
--3.
create or replace   PROCEDURE getEquip(dwr OUT sys_refcursor,
                               pID_EQUIP_KITS_INST in number default null) IS
  BEGIN
  
	case 
		when pID_EQUIP_KITS_INST is null
		then
  
    OPEN dwr FOR
      select cl.V_LONG_TITLE, u.V_USERNAME, fc.V_EXT_IDENT, ekt.v_name, getDecoder(ek.id_equip_kits_inst)  from scd_equip_kits ek
		join fw_contracts fc
		on fc.id_contract_inst=ek.id_contract_inst
		and fc.dt_start <= current_timestamp AND fc.dt_stop > current_timestamp
		and fc.v_status='A'
			join fw_clients cl
			on cl.ID_CLIENT_INST=fc.ID_CLIENT_INST
			and cl.dt_start <= current_timestamp AND cl.dt_stop > current_timestamp
				join ci_users u
				on u.ID_CLIENT_INST=fc.ID_CLIENT_INST
				and u.v_status='A'
					join scd_equipment_kits_type ekt
					on ekt.id_equip_kits_type=ek.id_equip_kits_type
					and ekt.dt_start <= current_timestamp AND ekt.dt_stop > current_timestamp
		where ek.dt_start <= current_timestamp AND ek.dt_stop > current_timestamp
		;
		when pID_EQUIP_KITS_INST is not null
		then 
		OPEN dwr FOR
		select cl.V_LONG_TITLE, u.V_USERNAME, fc.V_EXT_IDENT, ekt.v_name, getDecoder(ek.id_equip_kits_inst)  from scd_equip_kits ek
		join fw_contracts fc
		on fc.id_contract_inst=ek.id_contract_inst
		and fc.dt_start <= current_timestamp AND fc.dt_stop > current_timestamp
		and fc.v_status='A'
			join fw_clients cl
			on cl.ID_CLIENT_INST=fc.ID_CLIENT_INST
			and cl.dt_start <= current_timestamp AND cl.dt_stop > current_timestamp
				join ci_users u
				on u.ID_CLIENT_INST=fc.ID_CLIENT_INST
				and u.v_status='A'
					join scd_equipment_kits_type ekt
					on ekt.id_equip_kits_type=ek.id_equip_kits_type
					and ekt.dt_start <= current_timestamp AND ekt.dt_stop > current_timestamp
		where ek.dt_start <= current_timestamp AND ek.dt_stop > current_timestamp and ek.ID_EQUIP_KITS_INST=pID_EQUIP_KITS_INST
		;
		
	end case;
	EXCEPTION
	WHEN no_data_found THEN
   raise_application_error (-20020,'Нету');
  WHEN OTHERS THEN
    raise_application_error(-20020,
                            'Другая ошибка');
	

  END;
  /
--4. 
 CREATE OR REPLACE PROCEDURE checkstatus IS 
  
BEGIN
  FOR i IN (select distinct ek.id_equip_kits_inst, cl.V_LONG_TITLE, c.b_agency,  fc.v_ext_ident  from scd_equip_kits ek
  JOIN scd_equipment_status ses
                ON ses.id_equipment_status = ek.id_status
               AND ses.b_deleted = 0
              and ses.v_name <>'Продано'
			join fw_contracts fc
			on fc.id_contract_inst=ek.id_contract_inst
			and fc.dt_start <= current_timestamp AND fc.dt_stop > current_timestamp
			and fc.v_status='A'
				join fw_clients cl
				on cl.ID_CLIENT_INST=fc.ID_CLIENT_INST
				and cl.dt_start <= current_timestamp AND cl.dt_stop > current_timestamp
					JOIN scd_contracts c ON c.id_contract_inst = ek.id_contract_inst
						join scd_equipment_kits_type ekt
						on ekt.id_equip_kits_type=ek.id_equip_kits_type
						and ekt.dt_start <= current_timestamp AND ekt.dt_stop > current_timestamp
		where ek.dt_start <= current_timestamp AND ek.dt_stop > current_timestamp) LOOP
  
    
    update scd_equipment_status
      set v_name='Продано';
  
  if i.b_agency=1
	
	then
  dbms_output.put_line ('Для оборудования '||i.id_equip_kits_inst||' дилера '||i.V_LONG_TITLE||' с контрактом '||i.v_ext_ident||',являющегося агентской сетью был проставлен статус Продано.'); 
	else
	dbms_output.put_line ('Для оборудования '||i.id_equip_kits_inst||' дилера '||i.V_LONG_TITLE||' с контрактом '||i.v_ext_ident||',не являющегося агентской сетью был проставлен статус Продано.');
	end if;
  END LOOP;
  end;
  

