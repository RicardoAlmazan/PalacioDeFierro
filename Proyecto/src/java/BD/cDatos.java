package BD;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author Ricardo
 */
public class cDatos {

    private String usrBD;
    private String passBD;
    private String urlBD;
    private String driverClassName;
    private Connection conn = null;
    private Statement estancia;

    public cDatos() {
        //poner los datos apropiados
        /*this.usrBD = "root";
        this.passBD = "n0m3l0s3";
        this.urlBD = "jdbc:mysql://127.0.0.1:3306/palacio_de_hierro_gourmet?useSSL=false";*/
        this.usrBD = "traafsi1_richie";
        this.passBD = "24059910";
        this.urlBD = "jdbc:mysql://traaf.site:3306/traafsi1_palacio_de_hierro_gourmet?useSSL=false";
        this.driverClassName = "com.mysql.jdbc.Driver";
    }

    //Conexion a la BD
    public void conectar() throws SQLException {
        try {
            Class.forName(this.driverClassName).newInstance();
            this.conn = DriverManager.getConnection(this.urlBD, this.usrBD, this.passBD);

        } catch (Exception err) {
            System.out.println("Error " + err.getMessage());
        }
    }

    //Cerrar la conexion de BD
    public void cierraConexion() throws SQLException {
        this.conn.close();
    }

 public ResultSet consulta(String consulta) throws SQLException {
        this.estancia = (Statement) conn.createStatement();
        return this.estancia.executeQuery(consulta);
    }
}
