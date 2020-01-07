/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ldn;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author Don Pendejo
 */
public class modifiCarrito extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            HttpSession sesion = request.getSession();
            BD.cDatos sqlito = new BD.cDatos();
            ArrayList<carrito> carro = null;
            boolean contiene = false;
            if (request.getParameter("cantidad") != null) {
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    int cantidad = Integer.parseInt(request.getParameter("inputcantidad"));
                    carro = (ArrayList<carrito>) sesion.getAttribute("productosCarro");
                    for (carrito c : carro) {
                        if (c.getIdProducto() == id) {
                            contiene = true;
                            sqlito.conectar();
                            ResultSet rs = sqlito.consulta("select stock from datosProductos where id_producto = " + id);
                            if (rs.next()) {
                                if (Integer.parseInt(rs.getString("stock")) >= cantidad) {
                                    c.setCantidad(cantidad);
                                }
                            }
                            break;
                        }
                    }

                    if (!contiene) {
                        response.sendRedirect("");
                    } else {
                        response.sendRedirect("carrito.jsp");
                    }

                } catch (Exception e) {
                    out.print(e.getMessage());
                }
            } else {
                response.sendRedirect("");
            }

        }
    }

// <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
