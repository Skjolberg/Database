
/* Crear una función que devuelva la edad media de los empleados que hay en la base de datos.*/

DELIMITER $$;
DROP FUNCTION IF EXISTS edadMedia $$;
CREATE FUNCTION edadMedia ()
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE edadMedia INT DEFAULT NULL;
    SET edadMedia = NULL;
    SELECT ROUND(sum(year(now())-year(BirthDate))/count(EmployeeID)) INTO edadMedia FROM Employees;
RETURN(edadMedia);
END $$;
DELIMITER ;

SELECT edadMedia();

/* Crear un procedimiento que reciba una letra, recupere con un cursor todos los empleados
cuyo nombre comienza por dicha letra, los imprima uno a uno con un SELECT, y tras imprimir cada uno
los actualice también uno a uno para que el nombre aparezca en la base de datos en mayúsculas.*/

START TRANSACTION;
DELIMITER $$;
DROP PROCEDURE IF EXISTS recibeLetra $$;
CREATE PROCEDURE recibeLetra(IN letra VARCHAR(5)) /* Recibe un valor, pero no devuelve nada */
	
BEGIN 
	DECLARE lista VARCHAR(100) DEFAULT '';
    DECLARE FIN BOOL default 0;
    DECLARE name VARCHAR(100);
	DECLARE emp CURSOR FOR SELECT UPPER(FirstName) FROM Employees WHERE FirstName LIKE letra;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET FIN=1;
    OPEN emp;
    bucle: LOOP
    FETCH emp INTO name;
		IF FIN THEN
			LEAVE bucle;
		END IF;
        SET lista = name;
        SELECT lista;
        UPDATE Employees SET FirstName=UPPER(name) WHERE FirstName=name;
    END LOOP bucle;
    CLOSE emp;
END $$;
DELIMITER ;

SET @letra='A%';
CALL recibeLetra(@letra);


/* Crear triggers que comprueben si cada vez que se inserta o actualiza un empleado,
los campos LastName y FirstName son nulos. Si se trata de una inserción, hay que poner los campos
a una cadena vacía o a un valor por defecto. Si se trata de una actualización, hay que cancelar
la actualización.*/

-- Comprueba si el campo FirstName o LastName es NULL e inserta un nombre por defecto en el campo
DELIMITER $$
DROP TRIGGER IF EXISTS EMPLOYEES_BI $$
CREATE TRIGGER EMPLOYEES_BI
  BEFORE INSERT
  ON employees FOR EACH ROW
	BEGIN
	IF new.FirstName IS NULL THEN
		SET new.FirstName = 'default';
	END IF;
	IF new.LastName IS NULL THEN
		SET new.LastName = 'default';
	END IF;
END$$;
DELIMITER ;

INSERT INTO Employees SET FirstName=null, LastName=null;


-- Comprueba si el campo FirstName o LastName es NULL y si actualiza hay que cancelar dicha actualizacion
DELIMITER $$
DROP TRIGGER IF EXISTS EMPLOYEES_BU $$
CREATE TRIGGER EMPLOYEES_BU
  BEFORE UPDATE
  ON employees FOR EACH ROW
	BEGIN
	IF new.FirstName IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error, el campo introducido no debe ser null.';
	END IF;
	IF new.LastName IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error, el campo introducido no debe ser null.';
	END IF;
END$$;
DELIMITER ;

UPDATE Employees SET FirstName=null, LastName=null WHERE EmployeeID=1;
