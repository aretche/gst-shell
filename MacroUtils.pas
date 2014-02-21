    {Copyright (C) 2013-2014  Galante - Schab - Schab - Tommasi

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    Also add information on how to contact you by electronic and paper mail.}

unit MacroUtils;
interface
         uses
             BaseUnix, Unix, Unixtype, crt, SysUtils,DateUtils,users,unixutil,TDALista;      

         type
   	     salida= array of string;
             ArrayChar=array of char;
   
	 const
             meses: array[1..12] of string=('ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic');
             dias: array[1..31] of string=(' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 							 						9','10','11','12','13','14','15','16','17','18','19','20', 						'21','22','23','24','25','26','27','28','29','30','31');    
             numero: array[1..60] of string=('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20', 			         			'21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40',
			        		'41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60');

	 var usuarioActual,hostActual,dir,olddir,home,homeMasUsuarioActual,Entrada,Entrada2:string;
	     dat: ArrayChar;
             pid: longint;
	     idBg:TPid;	

	 procedure recibirSalida;
         procedure iniciarvariables;  
         procedure prompt;
	 function Descifrador(str: string; separator: string): salida;
	 function Lanzador(clave: salida): byte;
	 procedure lanzarExterno(entrada: string);
	 procedure analizarEntrada(str: string);
	 procedure analizarSalida(str: string);

implementation

         procedure iniciarvariables;    //inicia las variables internas que manejan el entorno del shell
           begin	
	    home:='/home';
            olddir:=home;
  	    usuarioActual:=fpgetenv('USER');
  	    hostActual:=gethostname;
  	    homeMasUsuarioActual:=(home+'/'+usuarioActual);   
  	    dir:=homeMasUsuarioActual; 
            Entrada2:=' ';
	   end;

         procedure prompt;      // muestra en pantalla el prompt
           begin	
	     write(usuarioActual,'@','-',hostActual,':');
     	     if copy(dir,1,length(homeMasUsuarioActual)) = homeMasUsuarioActual then
               write('~',copy(dir,length(homeMasUsuarioActual)+1,length(dir)))
	     else
               write(dir); 
	     if (usuarioActual = 'root') then	        
	       write('# ')	        
             else	
	       write('$ ');	        
	   end;

	 procedure devolverMensaje(str:string);    // Carga el mensaje de tipo string que se le pasa en la variable global  
	 var i,j:word;                             //dat de tipo ArrayChar del shell
	 begin
	   if High(dat)<1 then i:=1
	   else i:=High(dat)+1;
	   if i=1 then
             begin
               SetLength(dat,i+1); 
	       dat[i]:=#13;
	       inc(i);               
             end;
	   for j:=1 to length(str) do
   	     begin
	       SetLength(dat,i+1);
	       dat[i]:=str[j];
	       inc(i);
	     end;
           SetLength(dat,High(dat)+2); 
	   dat[i]:=#10;
	   dat[i+1]:=#13;	   
	 end;

	 procedure devolverDatos(info:ArrayChar);  // Carga el mensaje de tipo ArrayChar que se le pasa en la variable global
	 var i,j:word;				   // dat del mismo tipo del shell
	 begin
	   if High(dat)<1 then i:=1
	   else i:=High(dat)+1;
	   if i=1 then
             begin
               SetLength(dat,i+1); 
	       dat[i]:=#10;
	       inc(i);               
             end;
	   j:=1;
	   while (j <= High(info)) do
   	     begin
	       SetLength(dat,i+1);
	       dat[i]:=info[j];
	       inc(i);
	       inc(j);
	     end;
           SetLength(dat,High(dat)+2); 
	   dat[i]:=#10;
	   dat[i+1]:=#13;
	 end;

	 procedure mostrar(var datos: ArrayChar);   // Muestra en pantalla el contenido de la variable datos de tipo ArrayChar que se le pasa
	  var  i: word;
          begin
	    if High(datos)>0 then
              begin
                for i:= 1 to High(datos) do
                  Write(datos[i]);	        	 
              end;
	    SetLength(datos,0);   
          end;

	 procedure escribirArchivo(arch:string;var datos: ArrayChar); // guarda los datos que se le pasan en la variable datos de tipo ArrayChar
	 Var fd : Longint;					      // en el archivo de nombre arch. Si el archivo no existe lo crea 
	     i:word;						      // y si existe escribe los datos al final.
	 begin
           fd := FPOpen(arch,O_WrOnly OR O_Creat);
           if fpLSeek(fd,0,Seek_end)=-1 then   
             Writeln ('Error en el archivo!!!');
	   if fd > 0 then
	     begin
	       if High(datos)>0 then
	         for i:=1 to High(datos) do
	           if (FPWrite(fd,datos[i],1))=-1 then
                     Writeln ('Error al escribir en el archivo!!!');	 	
	       FPClose(fd);
	       SetLength(datos,0);
	     end;	   
	 end;

	 procedure reEscribirArchivo(arch:string;var datos: ArrayChar);// guarda los datos que se le pasan en la variable datos de tipo ArrayChar
	 Var fd : Longint;					       // en el archivo de nombre arch. Si el archivo no existe lo crea 
	     i:word;						       // y si existe lo sobreescribe.
	 begin							       //VER SI FUNCIONA FPTRUNCATE
           fd := FPOpen(arch,O_WrOnly OR O_Creat);
	   if fd > 0 then
	     begin
               if FpFtruncate(fd,0)<>0 then
                 Writeln ('Error con archivos!!!');
	       if High(datos)>0 then	 
	         for i:=1 to High(datos) do
	           if (FPWrite(fd,datos[i],1))=-1 then
                     Writeln ('Error al escribir en el archivo!!!');	 	
	       FPClose(fd);
	       SetLength(datos,0);	       
             end;
	 end;

	function verificarRuta(ruta:string): byte;   // Verifica que el string que se le pasa sea una ruta de directorio valida.
        begin
          {$I-}
          ChDir (ruta);
          if IOresult<>0 then
            verificarRuta:=0
	  else
            verificarRuta:=1;
	end;

	function rutaPadre(ruta:string): string;     // Recibe un string que posea '/' y devuelve otro en el cual ha eliminado el postfijo	
        begin                                        // que sigue a la ultima ocurrencia de '/'.
          while copy(ruta,length(ruta),length(ruta)) <> '/' do
	    ruta:=copy(ruta,1,length(ruta)-1);
          rutaPadre:=copy(ruta,1,length(ruta)-1);
	end;

	 procedure micd(ruta:string);  // Cambia el valor de la variable global dir (directorio de trabajo actual) segun el string que se le pasa
	begin
	  if (ruta='~') or (ruta=' ') then
            ruta:=homeMasUsuarioActual
	  else 
            if ruta='.' then
              ruta:=dir	
            else
              if ruta= '..' then
                begin
		  ruta:=rutaPadre(dir);
                end
              else
                if ruta= '-' then
                  begin
	  	    ruta:=olddir;
                  end
	        else
	          if copy(ruta,1,1) <> '/' then
                    begin
		      ruta:=dir+'/'+ruta;
                    end; 		//CUANDO EMPIEZA CON / NO SE HACE NADA PORQUE LA RUTA QUEDA ASI NOMAS
	  if verificarRuta(ruta)=1 then
            begin
              olddir:=dir;
              dir:=ruta;
            end  
          else
            begin
              devolverMensaje('Error ');
	      devolverMensaje(ruta);
	      devolverMensaje(': No existe el archivo o el directorio');
            end;
	end;

	 procedure analizarEntrada(str: string); // Analiza el string que se le pasa en la variable str. Busca si el string posee un caracter
	 var i,j:integer;			 // '|' o '>' y si existe alguno divide el string en la posicion en la que se encuentra
	 begin					// la primer ocurrencia y guarda en la variable global Entrada la primera parte
	   i:=pos('|',str);			// y en la variable global Entrada2 el resto del string.
	   j:=pos('>',str);
	   if (i>0) or (j>0) then
             begin
               if ((i<j) and (i<>0)) or (j=0) then
                 begin
		   Entrada:=copy(str,1,i-2);
		   Entrada2:=copy(str,i,length(str));
                 end
               else
                 if ((j<i) and (j<>0)) or (i=0) then
                   begin
		     Entrada:=copy(str,1,j-2);
		     Entrada2:=copy(str,j,length(str));		   
                   end;        
             end;	   
	 end;

	 function esInterno(c: string): boolean;  //Devuelve verdadero si el string que se le pasa coincide con el nombre de un comando interno
           begin
             if (c='milsl')or(c='milsa')or(c='milsf')or(c='micat')or(c='mikill')or(c='mipwd')or(c='micd') then
               esInterno:=1=1
             else
               esInterno:=1=0;
           end;

	 procedure analizarSalida(str: string); // Recibe como parametro en la variable str un string con las proximas ordenes a ejecutar.
	 var s:salida;			        // Si recibe ' ' significa que no hay mas ordenes a ejecutar y por lo tanto muestra el contenido
	 begin					// que mantiene almacenado en la variale global dat.
	   if str=' ' then			// En caso contrario analiza el string recibido actualizando las variables globales
             begin			        // Entrada y Entrada2 si hay un Pipe o guardando en un archivo la informacion de la variable  
               mostrar(dat);		        // dat si lo que hay es una redireccion de la salida estandar. 
      	       prompt;				// Luego si es necesario muestra el prompt y lee una nueva entrada.
      	       readln(Entrada);
             end
	   else
             begin
	       s:=Descifrador(copy(str,3,length(str)),' ');
	       if copy(str,1,1)='|' then
                 begin
	           if esInterno(s[1]) then
                     begin         
                       Entrada:=copy(str,3,length(str));    
                       Entrada2:=' ';
                     end 
		   else
                     begin
		       Entrada:=s[1]+' tuberia.txt'+copy(str,length(s[1])+3,length(str)); 
                       Entrada2:=' ';                 
                     end;		   		   
	         end
	       else           
                 if copy(str,1,2)='>>' then
                   begin
                     escribirArchivo(s[2],dat);
                     Entrada2:=' ';
      	             prompt;
      	             readln(Entrada);		     
                   end
                 else //'>'
                   begin
                     reEscribirArchivo(s[1],dat);
                     Entrada2:=' ';
      	             prompt;
      	             readln(Entrada);		     
                   end;                       
             end;	   
	 end;

         procedure mipwd;	// Carga en la variable global dat un string con la ruta del directorio actual.
	   begin
	     devolverMensaje(dir);
	   end;

 	function GetFilePermissions(mode: mode_t): string; // Recibe un dato de tipo mode_t y devuelve un string que muestra
 	var 						    // el tipo y los permisos del archivo para el usuario,el grupo y otros.
            Result: string;
	begin
	   Result:='';
	
	   if STAT_IFLNK and mode=STAT_IFLNK then	// file type
	     Result:=Result+'l'
	   else
	   if STAT_IFDIR and mode=STAT_IFDIR then
	     Result:=Result+'d'
	   else
	   if STAT_IFBLK and mode=STAT_IFBLK then
	     Result:=Result+'b'
	   else
	   if STAT_IFCHR and mode=STAT_IFCHR then
	     Result:=Result+'c'
	   else
	     Result:=Result+'-';

	   if STAT_IRUSR and mode=STAT_IRUsr then	// user permissions
	     Result:=Result+'r'
	   else
	     Result:=Result+'-';
	   if STAT_IWUsr and mode=STAT_IWUsr then
	     Result:=Result+'w'
	   else
	     Result:=Result+'-';
	   if STAT_IXUsr and mode=STAT_IXUsr then
	     Result:=Result+'x'
	   else
	     Result:=Result+'-';
	
	   if STAT_IRGRP and mode=STAT_IRGRP then	   // group permissions
	     Result:=Result+'r'
	   else
	     Result:=Result+'-';
	   if STAT_IWGRP and mode=STAT_IWGRP then
	     Result:=Result+'w'
	   else
	     Result:=Result+'-';
	   if STAT_IXGRP and mode=STAT_IXGRP then
	     Result:=Result+'x'
	   else
	     Result:=Result+'-';
	   
	   if STAT_IROTH and mode=STAT_IROTH then	// other permissions
	     Result:=Result+'r'
	   else
	     Result:=Result+'-';
	   if STAT_IWOTH and mode=STAT_IWOTH then
	     Result:=Result+'w'
	   else
	     Result:=Result+'-';
	   if STAT_IXOTH and mode=STAT_IXOTH then
	     Result:=Result+'x'
	   else
	     Result:=Result+'-';
	
	   GetFilePermissions:=Result;

	end;

	 procedure Completar(var str:string;num:word); // Recibe un string y devuelve otro de longitud num, que posee el primero pero 
	 begin						// que se completa con espacios (' ') hasta llegar al tamaño indicado
 	   while length(str)<num do			// Si el string que se le pasa tiene una longitud mayor a num devuelve el mismo
	    begin
	      str:=str+' ';
	    end;
	 end;

         procedure ListadolR(var L:T_LISTA;var cant:word;var total:word); //Guarda en la variable global dat el contenido de la lista
                  var Act: T_PUNTEROL;					  // y devuelve la cantidad de archivos y el tamaño total
	              lin,aux:string;					  
                  begin
                     act:=L.cabecera;
                     while (Act<>nil) do
                       begin
                           with Act^.info do
			     begin
				if copy(nombre,1,1)<>'.' then
				  begin 
				     lin:=permisos;
				     Completar(lin,12);
				     Str(nlink,aux);
				     lin:=lin+aux;
				     Completar(lin,14);
				     lin:=lin+usuario;
				     Completar(lin,22);
				     lin:=lin+grupo;
				     Completar(lin,30);
				     Str(tam,aux);
				     Completar(lin,37-length(aux));//para que el num quede alineado a la derecha
				     lin:=lin+aux;
				     Completar(lin,38);
				     lin:=lin+fecha;
				     Completar(lin,52);
				     lin:=lin+nombre;
				     inc(cant);
				     total:=total+tam;	
				     devolverMensaje(lin);
				  end;
                             end;
                         Act:=Act^.siguiente;
                       end;
                  end;

	 procedure milslR(ubicacion:string);  // Realiza el comando ls con la opcion -l guardando los datos en la variable global dat
	 var				      
	   D:TDateTime;			     
	   dire: Pdir;                      
	   entrada: Pdirent;                
	   archivo: stat;
	   YY,MM,DD,HH,MI,SS,MS,cant_archivos,ttotal : word ;
	   aux: T_DATOL; 
	   lis: T_LISTA;
	   cant,total,ubi:string;
	 begin
             ubi:=ubicacion;
	     cant_archivos:= 0;
	     ttotal:=0;
	     crearlista(lis);
	     if ubicacion<> ' ' then
	       begin
                 micd(ubicacion);
               end;
	     ubicacion:=dir;
	     dire:= fpOpenDir(ubicacion); 
	     if dire<>nil then
	       begin
	         repeat
	           entrada := fpReadDir(dire^);
		   with entrada^ do 
	             begin
	               if entrada <> nil then
	                 begin
	                    if fpLStat(pchar(@d_name[0]),archivo)=0  then 
		              begin		                        
	                        aux.permisos:=GetFilePermissions(archivo.st_mode);      // permisos
				aux.nlink:=archivo.st_nlink;        			// links 
	                        aux.usuario:=GetUserName(archivo.st_uid);      		// usuario 
			        aux.grupo:=GetGroupName(archivo.st_gid);        	// grupo 
			        aux.tam:=archivo.st_size;        			// tamanio 
	                        D:=UnixToDateTime(archivo.st_ctime);			// fecha de ultima modificacion
	                        DecodeDate (D,YY,MM,DD) ;
	                        DecodeTime (D,HH,MI, SS,MS) ;                            
	                        aux.fecha:=(meses[MM]+' '+dias[DD]+' '+numero[HH]+':'+numero[MI]);        	
				if (not(fpS_ISDIR(archivo.st_mode))) and (STAT_IXUsr and archivo.st_mode=STAT_IXUsr) then     //ejecutables
	                          aux.color:=10 {verde claro}
				else
	                          if fpS_ISREG(archivo.st_mode) then
				    aux.color:=15 {blanco}
				  else
				    if fpS_ISLNK(archivo.st_mode) then
				      aux.color:=11 {celeste claro}
	                            else
				      if fpS_ISDIR(archivo.st_mode) then
				        aux.color:=9;  {azul claro}                                 
				aux.clave:=upCase(pchar(entrada^.d_name));     //clave                        
				aux.nombre:=pchar(entrada^.d_name);     //nombre
	                        InsertarEnLista(lis,aux);			
			      end;
	                  end;
		        end;
	            until entrada = nil;
		    listadolR(lis,cant_archivos,ttotal);
	            Str(cant_archivos,cant);
		    Str(ttotal,total);
	            devolverMensaje('Cantidad de archivos: ');
		    devolverMensaje(cant); 
		    devolverMensaje('Total: ');
		    devolverMensaje(total);
	            fpCloseDir (dire^);
	         end
	      else
	        begin
		  devolverMensaje('Error en la lectura del directorio'); 
	        end;
             if ubi<> ' ' then
               micd('-');
	   end;


	 procedure milsl(ubicacion:string); // Realiza el comando ls con la opcion -l mostrando los datos en      
	 var				    // pantalla (se utiliza cuando no hay redireccion)
	   D:TDateTime;
	   dire: Pdir;
	   entrada: Pdirent;
	   archivo: stat;
	   YY,MM,DD,HH,MI,SS,MS,cant_archivos,ttotal : word ;
	   aux: T_DATOL; 
	   lis: T_LISTA;
           ubi:string;
	 begin
             ubi:=ubicacion;
	     cant_archivos:= 0;
	     ttotal:=0;
	     crearlista(lis);
	     if ubicacion<> ' ' then
	       begin
                 micd(ubicacion);
               end;
	     ubicacion:=dir;
	     dire:= fpOpenDir(ubicacion);
	     if dire<>nil then
	       begin
	         repeat
	           entrada := fpReadDir(dire^);
		   with entrada^ do 
	             begin
	               if entrada <> nil then
	                 begin
	                    if fpLStat(pchar(@d_name[0]),archivo)=0  then 
		              begin		                        
	                        aux.permisos:=GetFilePermissions(archivo.st_mode);      // permisos
				aux.nlink:=archivo.st_nlink;        			// links 
	                        aux.usuario:=GetUserName(archivo.st_uid);      		// usuario 
			        aux.grupo:=GetGroupName(archivo.st_gid);        	// grupo 
			        aux.tam:=archivo.st_size;        			// tamanio 
	                        D:=UnixToDateTime(archivo.st_ctime);			// fecha de ultima modificacion
	                        DecodeDate (D,YY,MM,DD) ;
	                        DecodeTime (D,HH,MI, SS,MS) ;                            
	                        aux.fecha:=(meses[MM]+' '+dias[DD]+' '+numero[HH]+':'+numero[MI]);        	
				if (not(fpS_ISDIR(archivo.st_mode))) and (STAT_IXUsr and archivo.st_mode=STAT_IXUsr) then     //ejecutables
	                          aux.color:=10 {verde claro}
				else
	                          if fpS_ISREG(archivo.st_mode) then
				    aux.color:=15 {blanco}
				  else
				    if fpS_ISLNK(archivo.st_mode) then
				      aux.color:=11 {celeste claro}
	                            else
				      if fpS_ISDIR(archivo.st_mode) then
				        aux.color:=9;  {azul claro}         	                          
				aux.clave:=upCase(pchar(entrada^.d_name));     //clave                        
				aux.nombre:=pchar(entrada^.d_name);     //nombre
	                        InsertarEnLista(lis,aux);				
			      end;
	                  end;
		        end;
	            until entrada = nil;
		    listadol(lis,cant_archivos,ttotal);
	            writeln('Cantidad de archivos: ',cant_archivos); 
		    writeln('Total: ',ttotal{ div 1024});
	            fpCloseDir (dire^);
	         end
	      else
	        begin
		  Write('Error en la lectura del directorio'); 
	        end;
             if ubi<> ' ' then
               micd('-');
	   end;

         procedure ListadoaR(var L:T_LISTA);//Guarda en la variable global dat el contenido de la lista					  
                  var Act: T_PUNTEROL;	    
                  begin
                     act:=L.cabecera;
                     while (Act<>nil) do
                       begin
                           with Act^.info do
			     begin				     	
                                devolverMensaje(nombre);
                             end;
                         Act:=Act^.siguiente;
                       end;
                     textcolor(15);
                  end;


         procedure milsaR(ubicacion:string); // Realiza el comando ls con la opcion -a guardando los datos en la variable global dat
	   var
	     dire: Pdir;
	     entrada: Pdirent;
	     archivo: stat;
	     cant_archivos: cardinal;
	     aux: T_DATOL; 
	     lis: T_LISTA;
	     cant,ubi:string;
	   begin
             ubi:=ubicacion;
	     cant_archivos:= 0;
	     crearlista(lis);
	     if ubicacion<> ' ' then
	       begin
                 micd(ubicacion);
               end;
	     ubicacion:=dir;
	     dire:= fpOpenDir(ubicacion);
	     if dire<>nil then
	       begin
	         repeat
	           entrada := fpReadDir(dire^);
		   with entrada^ do 
	             begin
	               if entrada <> nil then
	                 begin
	                    inc(cant_archivos);
	                    if fpStat(pchar(@d_name[0]),archivo)=0  then 
		              begin
				aux.clave:=upCase(pchar(entrada^.d_name));     //clave                        
				aux.nombre:=pchar(entrada^.d_name);     //nombre
	                        InsertarEnLista(lis,aux);
			      end;
	                  end;
		       end;
	           until entrada = nil;
		   ListadoaR(lis);
	           devolverMensaje('Cantidad de archivos: ');
		   Str(cant_archivos,cant); 
		   devolverMensaje(cant);
	           fpCloseDir (dire^);
	         end
	      else
	        begin
		  Write('Error en la lectura del directorio'); 
	        end;
             if ubi<> ' ' then
               micd('-');
	   end;

           procedure milsa(ubicacion:string); // Realiza el comando ls con la opcion -a mostrando los datos en      
	   var				      // pantalla (se utiliza cuando no hay redireccion)
	     dire: Pdir;
	     entrada: Pdirent;
	     archivo: stat;
	     cant_archivos: cardinal;
	     aux: T_DATOL; 
	     lis: T_LISTA;
             ubi:string;
	   begin
             ubi:=ubicacion;
	     cant_archivos:= 0;
	     crearlista(lis);
	     if ubicacion<> ' ' then
	       begin
                 micd(ubicacion);
               end;
	     ubicacion:=dir;
	     dire:= fpOpenDir(ubicacion);
	     if dire<>nil then
	       begin
	         repeat
	           entrada := fpReadDir(dire^);
		   with entrada^ do 
	             begin
	               if entrada <> nil then
	                 begin
	                    inc(cant_archivos);
	                    if fpStat(pchar(@d_name[0]),archivo)=0  then 
		              begin
	                        if (not(fpS_ISDIR(archivo.st_mode))) and (STAT_IXUsr and archivo.st_mode=STAT_IXUsr) then //ejecutables
	                           aux.color:=10 {verde claro}
				 else
	                           if fpS_ISREG(archivo.st_mode) then
				    aux.color:=15 {blanco}
				   else
				     if fpS_ISLNK(archivo.st_mode) then
				       aux.color:=11 {celeste claro}
	                             else
				       if fpS_ISDIR(archivo.st_mode) then
				         aux.color:=9;  {azul claro}         	                          
				aux.clave:=upCase(pchar(entrada^.d_name));     //clave                        
				aux.nombre:=pchar(entrada^.d_name);     //nombre
	                        InsertarEnLista(lis,aux);
			      end;
	                  end;
		       end;
	           until entrada = nil;
		   Listadoa(lis);
	           writeln('Cantidad de archivos: ',cant_archivos); 
	           fpCloseDir (dire^);
	         end
	      else
	        begin
		  Write('Error en la lectura del directorio'); 
	        end;
             if ubi<> ' ' then
               micd('-');
	   end;
	
         procedure milsfR(ubicacion:string);   // Realiza el comando ls con la opcion -f guardando los datos en la variable global dat	
	 var
	   dire: Pdir;
	   entrada: Pdirent;
	   archivo: stat;
	   cant_archivos: cardinal;
	   cant,ubi:string;
	 begin
             ubi:=ubicacion;
	     cant_archivos:= 0;
	     if ubicacion<> ' ' then
	       begin
                 micd(ubicacion);
               end;
	     ubicacion:=dir;
	     dire:= fpOpenDir(ubicacion);
	     if dire<>nil then
	       begin
	         repeat
	           entrada := fpReadDir(dire^);
		   with entrada^ do 
	             begin
	               if entrada <> nil then
	                 begin
	                    inc(cant_archivos);
	                    if fpStat(pchar(@d_name[0]),archivo)=0  then 
		              begin		                          
	                        devolverMensaje(pchar(entrada^.d_name));     //nombre
			      end;
	                end;
		     end;
	         until entrada = nil;
	         Str(cant_archivos,cant);
	         devolverMensaje('Cantidad de archivos: ');
		 devolverMensaje(cant); 	
	         fpCloseDir (dire^);
	      end
	    else
	      begin
		devolverMensaje('Error en la lectura del directorio'); 
	      end;
             if ubi<> ' ' then
               micd('-');
	 end;

	function Descifrador(str: string; separator: string): salida;  // Se le pasa el string en str y el string que separa las palabras en 
	var							       // separador y devuelve un array of string con las palabras desde 
	  i,n: integer;						       // la pos 1 y el ultimo lugar vacio
	  strfield: string;
	  Result: salida;
	begin
	  n:= length(str);
	  SetLength(Result, n + 1);
	  i := 1;
	  repeat
	    if Pos(separator, str) > 0 then
	      begin
	        strfield:= Copy(str, 1, Pos(separator, str) - 1);
	        if length(str)>=Pos(separator,str)+1 then
	      	  str:= Copy(str, Pos(separator,str)+1,Length(str))
		else
	          str:=#0;
	      end
	    else
	      begin
	        strfield:= str;
	        str:= '';
	      end;
	    Result[i]:= strfield;
	    Inc(i);
	  until str= '';
	  SetLength(Result, i);
	  Descifrador:=Result;
	end;

	procedure mikill(S1,S2:string);  // Envia al proceso de pid S1 la señal S2
	var
	   code1,code2,P1,P2: word;
	begin
	   if (S1<>'-1') and (S2<>'-1') then 
	     begin
	       val(S1,P1,code1);
	       val(S2,P2,code2);
	         if (code1 = 0) and (code2 = 0) then
	           begin
	             Fpkill(P1,P2);
	           end
	         else
	           begin
	             devolverMensaje('Error en los parametros');
	           end; 
	     end
	   else     {Devuelve y explica el error si no se le pasa bien la cantidad de parametros que necesita}
	     begin 
	       devolverMensaje('El proceso necesita 2 parametros: pid del proceso - senial');
	     end;
	end;

         procedure micat;   //Lee los datos de la variable global dat y  lee de la entrada estandar.	
	 var		    //Luego guarda nuevamente todos los datos en la variable global dat.
            i: word;
	    a: char;
	    datos: ArrayChar;
	 begin
	   datos:=dat;
	   SetLength(dat,0);
	   if High(datos)<1 then i:=1
	   else i:=High(datos)+1;
           a:=readkey;
	   while a<>#13 do
             begin
               write(a); 
	       SetLength(datos,i+1); 
               datos[i]:=a;
               inc(i);
               a:=readkey;   
             end;
	   devolverDatos(datos);
	 end;

    	 function ConcatArray(a, b: ArrayChar): ArrayChar; // Concatena dos array de tipo char
       	 var i: Longint;
       	 begin
  	   SetLength(ConcatArray, Length(a) + Length(b));
  	   for i := 0 to High(a) do
     	     ConcatArray[i] := a[i];
 	   for i := 0 to High(b) do
     	     ConcatArray[i + Length(a)] := b[i];
         end;

	 procedure micat1(arch1:string); //Lee los datos de la variable global dat y del archivo de nombre arch1
	  var  fd : Longint;		 //Luego guarda todos los datos en la variable global dat.
               datos,info: ArrayChar;
               i: word;
               archivo: Stat;
          begin
	    info:=dat;
	    SetLength(dat,0);
            if fpStat(arch1,archivo)=0 then
              begin
                fd := fpOpen(arch1,O_RdOnly);
	        if fd>0 then
	          begin
                    SetLength(datos,archivo.st_size+1);
		    for i:= 1 to archivo.st_size do
                      begin
			if fpRead(fd,datos[i],1) < 0 then
	       	          begin
	       	            devolverMensaje('Error leyendo archivo!!!');
	       	          end;                        
                      end;	            
	          end;
	        fpClose(fd);
              end;
            info:=ConcatArray(info,datos);   
	    devolverDatos(info);
          end;

         procedure micat2(arch1:string; arch2:string); //Lee los datos de la variable global dat y de los archivos de nombre arch1 y arch2
	  var  fd : Longint;			       //Luego guarda nuevamente todos los datos en la variable global dat.
               datos,info: ArrayChar;
               i: word;
               archivo: Stat;
          begin
	    datos:=dat;
	    SetLength(dat,0);
            if fpStat(arch1,archivo)=0 then
              begin
                fd := fpOpen(arch1,O_RdOnly);
	        if fd>0 then
	          begin
                    SetLength(info,archivo.st_size+1);
		    for i:= 1 to archivo.st_size do
                      begin
			if fpRead(fd,info[i],1) < 0 then
	       	          begin
			    devolverMensaje(arch1);
	       	            devolverMensaje(': Error leyendo archivo!!!');
	       	          end;                        
                      end;	            
	          end;
	        fpClose(fd);
              end;
            info:=ConcatArray(datos,info);	    
            if fpStat(arch2,archivo)=0 then
              begin
                fd := fpOpen(arch2,O_RdOnly);
	        if fd>0 then
	          begin
                    SetLength(datos,archivo.st_size+1);
		    for i:= 1 to archivo.st_size do
                      begin
			if fpRead(fd,datos[i],1) < 0 then
	       	          begin
			    devolverMensaje(arch2);
	       	            devolverMensaje(': Error leyendo archivo!!!');
	       	          end;                        
                      end;	            
	          end;	        
	        fpClose(fd);
              end;
            info:=ConcatArray(info,datos);   
	    devolverDatos(info);
          end;

	 procedure mibg(P1: string);      // Recibe el pid de un proceso en P1, si es un pid valido le envia la señal de pausado
	 var	                          // y guarda el pid.
	 senialPausado: cint;
	 cod: word;
	 pid: longint;
	 begin                       
           val(P1,pid,cod);
   	   idBg:=pid;
     	   senialPausado:=SIGSTOP;
     	   if (pid<>-1) then 
     	     begin
     	       if (cod = 0) then
     	         Fpkill(pid,senialPausado);
     	       writeln('PID: ',pid,' se encuentra pausado en 2do Plano');
     	     end
	 end;

	 procedure mifg(P1: string);	// Recibe el pid de un proceso en P1, si es un pid valido le envia la señal de Resumen
	 var 				// si no recibe un pid (recibe -1) entonces envia la señal al ultimo proceso que fue pausado
	    senialResumen: cint;
	    cod: word;
	    pid: longint;
	 begin
	   val(P1,pid,cod);
	   senialResumen:=SIGCONT; //Enviamos la señal para traer el proceso a primer plano
   	   if (pid<>-1) then 
             begin
               if (cod = 0) then
                 Fpkill(pid,senialResumen);
               writeln('PID: ',pid,' se encuentra corriendo en 1er Plano');
             end
	   else 
             begin
               Fpkill(idBg,senialResumen);
               writeln('PID: ',idBg,' se encuentra corriendo en 1er Plano');
             end;
	 end;
		
	 function Lanzador(clave: salida): byte; // Recibe un array of strings en la variable clave y analiza que conmando lanzar.
	 var str: string; 			 // Si encontro el programa a lanzar, lo lanza y devuelve 1, si no devuelve 0.
	 begin
	   Lanzador:=1;
	   str:=clave[1];
	   if str='milsl' then	
	     begin
                 if Entrada2=' ' then
	           case High(clave) of
                     1:milsl(' ');
                     2:milsl(clave[2]);
                   end 
                 else
		   case High(clave) of
                     1:milslR(' ');
                     2:milslR(clave[2]);
                   end;   			
             end
           else
             if str='milsa' then
	       begin
                 if Entrada2=' ' then
		   case High(clave) of
                     1:milsa(' ');
                     2:milsa(clave[2]);
                   end
                 else
		   case High(clave) of
                     1:milsaR(' ');
                     2:milsaR(clave[2]);
                   end; 		
               end
             else
               if str='milsf' then
		 begin
		   case High(clave) of
                     1:milsfR(' ');
                     2:milsfR(clave[2]);
                   end;				
                 end
               else 
		 if str='micat' then
		   case High(clave) of
                       1:micat;
                       2:micat1(clave[2]);
		       3:micat2(clave[2],clave[3]);					
                   end
		 else
		   if str='micd' then
                     begin
                       case High(clave) of
                         1:  micd(' ');
                         2:  micd(clave[2]);		
                       end;
                       mipwd;
                     end
		   else
                     if str='mipwd' then
                       mipwd
		     else 
		       if str='mikill' then
		         case High(clave) of
                           1:mikill('-1','-1');
                           2:mikill(clave[2],'-1');
		           3:mikill(clave[2],clave[3]);					
                         end
	               else 
		         if str='mibg' then
                           case High(clave) of
                             1:  mibg('-1');
                             2:  begin
			           mibg(clave[2]);
			         end;		
                           end	             	
	                 else
	                   if str='mifg' then
                             case High(clave) of
                               1:  mifg('-1');
                               2:  begin
			             mifg(clave[2]);
			           end;		
                             end
	                   else
                            begin
		              Lanzador:=0;
                            end; 
     	 end;

	 function abrirArchivo(arch:string): Longint; // abre el archivo de nombre arch para escritura y si no existe lo crea
	 Var fd : Longint;			      // devuelve el descriptor de archivo							
	 begin				
           fd := FPOpen(arch,O_WrOnly OR O_Creat);
	   if fd > 0 then
	     begin
               if FpFtruncate(fd,0)<>0 then
                 Writeln ('Error con archivos!!!');	 	
	     end;
           abrirArchivo:=fd;
	 end;

	 procedure recibirSalida;     // Lee y guarda en la variable dat el contenido de los archivos 'salida.txt' y 'errores.txt'
	 begin			      // Luego elimina dichos archivos ademas de 'tuberia.txt'
           micat1('salida.txt'); 
           micat1('errores.txt');
           DeleteFile('salida.txt');
           DeleteFile('errores.txt');
           DeleteFile('tuberia.txt');
	 end;

	 procedure lanzarExterno(entrada: string); // Lanza un programa externo que se le pasa como string,
	 var 					   // enviandole datos en el archivo tuberia.txt.
  	    programa: string;			   // Además cierra la salida estandar (1) y la salida de error estandar (2) 
  	    PP: PPchar;         		   // y abre dos archivos ('salida.txt' y 'errores.txt') para que reciban esos datos.
	 begin
           programa:='cd '+dir+'; '+entrada;
	   reEscribirArchivo('tuberia.txt',dat);						
	   if Entrada2<>' ' then
             begin
	       if fpClose(1)<>0 then
                 Writeln ('Error en el archivo!!!');							
	       if abrirArchivo('salida.txt')< 0 then
                 Writeln ('Error en el archivo!!!'); 
	       if fpClose(2)<>0 then
                 Writeln ('Error en el archivo!!!');
	       if abrirArchivo('errores.txt')< 0 then
                 Writeln ('Error en el archivo!!!');
             end;
	   PP:=CreateShellArgV(programa);
           programa:=PP[0];         
           fpExecvp(programa, PP);
	 end;

BEGIN
END.
