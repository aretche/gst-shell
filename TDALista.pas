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

unit TDALista;
interface
         uses
               crt;

         type   T_DATOL= record
                            clave:string;
                            nombre:string;  
                            color:byte;
			    permisos:string;
			    nlink:byte;
			    usuario:string;
			    grupo:string;
			    tam:word;
			    fecha:string;  
                         end;

                T_PUNTEROL= ^T_NODOL;

                T_NODOL= Record
                           Info: T_DATOL;
                           Siguiente: T_PUNTEROL;
                        end;

                T_LISTA= Record
                           Cabecera: T_PunteroL;
                           Tamanio: Cardinal;
                        end;

         procedure CrearLista(var L:T_LISTA);	// Crea una lista dinamica vacía y la devuelve en la variable L

         procedure InsertarEnLista(var L:T_LISTA; x:T_DATOL);// Inserta ordenadamente el elemento que recibe en la variable x, en la lista L

	 procedure Listadoa(var L:T_LISTA);	// Realiza un listado de los datos de la lista con el formato del comando ls -a

         procedure Listadol(var L:T_LISTA;var cant:word;var total:word);// Realiza un listado de los datos de la lista con el 
									// formato del comando ls -l

implementation

         procedure CrearLista(var L:T_LISTA);
                   begin
                     L.cabecera:=nil;
                     L.tamanio:=0;
                   end;

         procedure InsertarEnLista(var L:T_LISTA; x:T_DATOL);
                  var Ant,Act,DirAux: T_PUNTEROL;
                  begin
                    new(DirAux);
                    DirAux^.Info:=x;
                    if (L.cabecera=nil) or (L.cabecera^.info.clave>x.clave) then
                      begin
                        DirAux^.siguiente:=L.cabecera;
                        L.cabecera:=DirAux;
                      end
                    else
                      begin
                        Ant:=L.cabecera;
                        Act:=L.cabecera^.siguiente;
                        while (Act<>nil) and (Act^.info.clave<=x.clave) do
                          begin
                            ant:=act;
                            act:=act^.siguiente
                          end;
                        diraux^.siguiente:=act;
                        ant^.siguiente:=diraux;
                      end;
                    Inc(L.tamanio);
                  end;

         procedure Listadoa(var L:T_LISTA);
                  var Act: T_PUNTEROL;
                  begin
                     act:=L.cabecera;
                     while (Act<>nil) do
                       begin
                           with Act^.info do
			     begin				     
				textcolor(color);	
                                writeln(nombre);
                             end;
                         Act:=Act^.siguiente;
                       end;
                     textcolor(15);
                  end;

         procedure Listadol(var L:T_LISTA;var cant:word;var total:word);
                  var Act: T_PUNTEROL;
                  begin
                     act:=L.cabecera;
                     while (Act<>nil) do
                       begin
                           with Act^.info do
			     begin
				if copy(nombre,1,1)<>'.' then
				  begin
                                     textcolor(15);				     
				     write(permisos);
				     gotoxy(12,WhereY);
				     write(nlink);
				     gotoxy(14,WhereY);
				     write(usuario);
				     gotoxy(22,WhereY);
				     write(grupo);
				     gotoxy(30,WhereY);
				     write(tam:7);
				     gotoxy(38,WhereY);
				     write(fecha);
				     gotoxy(52,WhereY);				
				     textcolor(color);	
                                     writeln(nombre);
				     inc(cant);
				     total:=total+tam;	
				  end;
                             end;
                         Act:=Act^.siguiente;
                       end;
                     textcolor(15);
                  end;

begin

end.
