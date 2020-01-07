import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author Ricardo
 */
public class consultas extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession sesion = request.getSession();

        String usuario, contra, mensaje = "";

        usuario = "Ricardo";//request.getParameter("usuario");
        contra = "12345";//request.getParameter("contra");
        BD.cDatos sqlito = new BD.cDatos();
        try {
            sqlito.conectar();
            ResultSet rs = sqlito.consulta("call validaLogin('" + usuario + "', '" + contra + "');");
            if (rs.next()) {
                mensaje = rs.getString("msj");
            }else{
                mensaje  = "Buuuu";
            }
        } catch (Exception e) {
            mensaje  = "Buuuu, no sirve";
        }
        
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Prueba de que Tony Stark tiene corazón.</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Prueba de que Tony Stark tiene corazón.</h1>");
            out.println("<h3> "+ mensaje+"</h3>");
            out.println("<a href='index.html'>Volver</a>");
            out.println("</body>");
            out.println("</html>");
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
