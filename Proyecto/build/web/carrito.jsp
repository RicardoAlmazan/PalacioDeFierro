<%-- 
    Document   : carrito
    Created on : 02-jun-2019, 17:40:31
    Author     : Ricardo
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="ldn.carrito"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    int idProd, prodCar = 0, tiempo = 1000;
    String pagina = "", textoModal = "", tituloModal = "";
    boolean muestraScript = false;
    BD.cDatos sql = new BD.cDatos();
    ResultSet rs = null;
    ArrayList<carrito> carro = new ArrayList<carrito>();

    if (request.getParameter("pagar") != null && session.getAttribute("productosCarro") != null) {
        try {
            sql.conectar();
            carro = (ArrayList<carrito>) session.getAttribute("productosCarro");
            for (carrito c : carro) {
                rs = sql.consulta("call insertarProductosCarrito(" + c.getIdProducto() + ", 1, " + c.getCantidad() + ");");
                if (rs.next()) {
                    if (rs.getString("msj").equals("No")) {
                        out.print("valio madre");
                    }
                }
            }
        } catch (Exception e) {
            out.print(e.getMessage());
        } finally {
            sql.cierraConexion();
        }
        session.removeAttribute("productosCarro");
    }

    if (request.getParameter("agregarProducto") != null) {
        try {
            idProd = Integer.parseInt(request.getParameter("agregarProducto"));
            if (session.getAttribute("productosCarro") != null) {
                boolean contiene = false;
                carro = (ArrayList<carrito>) session.getAttribute("productosCarro");
                for (carrito c : carro) {
                    if (c.getIdProducto() == idProd) {
                        contiene = true;
                        break;
                    }
                }
                if (!contiene) {
                    carro.add(new carrito(idProd, 1));
                    prodCar = carro.size();
                    pagina = "http://localhost:8080/Proyecto/carrito.jsp";
                    muestraScript = true;
                    tiempo = 2000;
                    tituloModal = "Se agregó el articulo.";
                    textoModal = "El articulo seleccionado ha sido agregado al carrito.";
                } else {
                    muestraScript = true;
                    pagina = "http://localhost:8080/Proyecto/carrito.jsp";
                    tituloModal = "Articulo existente.";
                    textoModal = "El articulo seleccionado ya se ha agregado al carrito antes.";
                }
            } else {
                carro = new ArrayList<carrito>();
                carro.add(new carrito(idProd, 1));
                session.setAttribute("productosCarro", carro);
                prodCar = carro.size();
                tiempo = 2000;
                pagina = "http://localhost:8080/Proyecto/carrito.jsp";
                muestraScript = true;
                tituloModal = "Se agregó el articulo.";
                textoModal = "El articulo seleccionado ha sido agregado al carrito.";
            }
        } catch (Exception e) {
            out.print(e.getMessage());
        }
    } else {
        if (session.getAttribute("productosCarro") != null) {
            carro = (ArrayList<carrito>) session.getAttribute("productosCarro");
            prodCar = carro.size();
        } else {
            if (request.getParameter("pagar") != null) {
                pagina = "http://localhost:8080/Proyecto/";
                tituloModal = "Check Out";
                textoModal = "Se ha vaciado el carrito.";
                muestraScript = true;
            } else {
                pagina = "http://localhost:8080/Proyecto/";
                tituloModal = "El carrito está vacio.";
                textoModal = "No hay productos agregados al carrito.";
                muestraScript = true;
            }
        }
    }

    if (request.getParameter("eliminarProducto") != null) {
        try {
            idProd = Integer.parseInt(request.getParameter("eliminarProducto"));
            if (session.getAttribute("productosCarro") != null) {
                carro = (ArrayList<carrito>) session.getAttribute("productosCarro");
                for (int i = 0; i < carro.size(); i++) {
                    if (carro.get(i).getIdProducto() == idProd) {
                        carro.remove(i);
                        pagina = "http://localhost:8080/Proyecto/carrito.jsp";
                        muestraScript = true;
                        if (carro.isEmpty()) {
                            tituloModal = "Se ha vaciado el carrito.";
                            textoModal = "El carrito ya no tiene articulos.";
                            pagina = "http://localhost:8080/Proyecto/";
                            session.removeAttribute("productosCarro");
                        } else {
                            tiempo = 2000;
                            tituloModal = "Articulo eliminado.";
                            textoModal = "Se eliminó el articulo con id " + idProd;
                        }
                        break;
                    }
                }
            } else {
                tiempo = 1000;
                pagina = "http://localhost:8080/Proyecto/";
                muestraScript = true;
                tituloModal = "Sin artículos.";
                textoModal = "El carrito no tiene articulos que eliminar.";
            }
        } catch (Exception e) {
            out.print(e.getMessage());
        }
    }

%>
<!DOCTYPE html>
<html>
    <head>

        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="description" content="">
        <meta name="author" content="">

        <title>Palacio de Fierro</title>

        <!-- Bootstrap core CSS -->
        <link href="css/bootstrap.min.css" rel="stylesheet">

        <!-- Custom styles for this template -->
        <link href="css/shop-homepage.css" rel="stylesheet">

    </head>
    <body>
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
            <div class="container">
                <a class="navbar-brand" href="/Proyecto/">Palacio de Fierro</a>
                <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarResponsive">
                    <ul class="navbar-nav ml-auto">
                        <li class="nav-item">
                            <a class="nav-link" href="/Proyecto/">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="#">Carrito(<%=prodCar%>)
                                <span class="sr-only">(current)</span></a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
        <!-- Page Content -->
        <div class="container">

            <div class="row">

                <div class="col-lg-3">

                    <h1 class="my-4">Palacio de Fierro</h1>
                    <div class="list-group">
                        <%try {
                                sql.conectar();
                                rs = sql.consulta("select name from categoria;");
                                while (rs.next()) {
                        %>
                        <a href="/Proyecto/?categoria=<%out.print(rs.getString("name"));%>" class="list-group-item"><%out.print(rs.getString("name"));%></a>
                        <%}
                            } catch (Exception ex) {
                                out.println(ex.getMessage());
                            } finally {
                                sql.cierraConexion();
                            }%>
                    </div>                
                </div>
                <div class="col-lg-9">
                    <div class="card card-outline-secondary my-4">
                        <div class="card-header">
                            <h2>Productos en el carrito.</h2>
                        </div>
                        <div class="card-body">
                            <%try {
                                    sql.conectar();
                                    for (carrito c : carro) {
                                        rs = sql.consulta("call getDatosProducto(" + c.getIdProducto() + ");");
                                        if (rs.next()) {
                            %>
                            <div class="col-lg-2 float-right">
                                <br>
                                <img class="card-img-top" src="images<%=rs.getString("img")%>" alt=""></div>
                            <h3><%=rs.getString("nombre")%></h3>
                            <p><%=rs.getString("descripcion")%></p>
                            <form class="form-inline" action="modifiCarrito?id=<%=c.getIdProducto()%>" method="POST">
                                <label class="form-control mb-2 mr-sm-2 mb-sm-0">$<%=rs.getString("precio")%></label>
                                <label class="form-control mb-2 mr-sm-2 mb-sm-0">X</label>
                                <div class="input-group mb-2 mr-sm-2 mb-sm-0">
                                    <input type="number" name="inputcantidad" id ="inputcantidad" value="<%=c.getCantidad()%>" min="1" max="<%=rs.getString("stock")%>">
                                </div>
                                <label class="form-control mb-2 mr-sm-2 mb-sm-0">=</label>
                                <label class="form-control mb-2 mr-sm-2 mb-sm-0">$<%=c.getCantidad() * Float.parseFloat(rs.getString("precio"))%></label>
                                <div class="input-group mb-2 mr-sm-2 mb-sm-0">
                                    <input type="submit" class="btn btn-secondary" value="Actualizar" name="cantidad" id="cantidad">
                                </div>
                            </form>
                            <a href="?eliminarProducto=<%=rs.getString("id_producto")%>" class="btn btn-danger float-right">Eliminar</a>
                            <hr><%
                                        }
                                    }
                                } catch (Exception e) {
                                    System.out.println(e.getMessage());
                                } finally {
                                    sql.cierraConexion();
                                }%>
                            <a href="?pagar=1" class="btn btn-success">Pagar</a>
                        </div>
                    </div>
                    <!-- /.card -->

                </div>
                <!-- /.col-lg-9 -->


            </div>
            <!-- /.row -->

            <!-- Modal -->
            <div class="modal fade" id="ventanaError" tabindex="-1" role="dialog" aria-labelledby="ventanaErrorTitle" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLongTitle"><%=tituloModal%></h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <%=textoModal%>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-dark" data-dismiss="modal">Aceptar</button>
                        </div>
                    </div>
                </div>
            </div>

        </div>
        <!-- /.container -->

        <!-- Footer -->
        <footer class="py-5 bg-dark">
            <div class="container">
                <p class="m-0 text-center text-white">Copyright &copy; Palacio de Fierro 2019</p>
            </div>
            <!-- /.container -->
        </footer>

        <!-- /.col-lg-3 -->
        <script src="jquery/jquery.min.js"></script>
        <script src="js/bootstrap.bundle.min.js"></script>
        <%=muestraScript ? "<script>"
                + "var pagina = '" + pagina + "'; "
                + "var explode = function(){$(location).attr('href',pagina);};"
                + "$(document).ready(function(){$('#ventanaError').modal('show');});"
                + "setTimeout(explode, " + tiempo + ");"
                + "</script>" : ""%>
    </body>
</html>
