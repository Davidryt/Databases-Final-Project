CREATE TRIGGER tr1
  INSTEAD OF DELETE ON tc
BEGIN
  UPDATE clubs set END_DATE=SYSDATE WHERE name=:OLD.name;
END;
/