create table Usuarios (
	ID varchar(12) not null,
	nombres varchar not null,
	apellidos varchar not null,
	nombre_usuario varchar not null,
	contraseña varchar not null,
	correo varchar not null,
	tipo_de_usuario varchar not null,
	constraint Usuarios_pk primary key (ID)
);

insert into Usuarios values('102014567','Juan Camilo','Ruiz Ortiz','juanks','pwd_jcruiz','juankruizo10@gmail.com','veedor');
insert into Usuarios values('123456','Nombre admin','Apellidos','admin_1', 'pwd_admin','juancamilo.ruiz@urosario.edu.co','admin');