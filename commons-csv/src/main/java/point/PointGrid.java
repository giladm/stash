package point;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.UUID;
import java.math.BigDecimal;
import java.math.RoundingMode;

/*
 *
 * This program creates 6400 ocean points and saves in a data structure.
 * It reads csv file and creates sql insert statements for Simple Location Entity
 * Output : sql insert statements for entry, exit
 * Output gets written to output.txt file
 *
 * file input:  60
 * out          61
 * org:         54
 * regionId     88,93,98 (+exit, entry)
 * fake/real    100
 * radius (real)107
 */

public class PointGrid {

    public static void main(String[] args) {

        PrintWriter writer = null;
        try {

            int x, y;
            double xcor, ycor;
            Point[] points = new Point[6400];
            int index = 0;
            for (x = 0, xcor = -69.355596; x < 80; x++) {
                System.out.println();
                System.out.println();
                for (y = 0, ycor = -99.492432; y < 80; y++) {

                    ycor = ycor - 0.3;

                    points[index] = new Point(getDecimalFormatted(xcor, 6), getDecimalFormatted(ycor, 6));
                    //System.out.println(index + " : " + points[index]);
                    index++;

                }
                xcor = xcor + 0.3;
            }
            int[] creatorUserIds = {113062}; //{212875};
            int[] modifierIds = {113062}; //{212875};
            int[] organizationIds ={223349};// {212882-macys};173514-me 224878-aerlingus 218341-andrew
            index = 0;

//            writer = new PrintWriter("dublin4locations.txt", "UTF-8");
            writer = new PrintWriter("output-aerlingus091214.out", "UTF-8");
//            final String csvFile = "/Users/gilad/Documents/Customers/AerLingus/geofence/dublin4locations.csv"; // aer lingus
//            final String csvFile = "/Users/gilad/Documents/Customers/Macys/Loc-Oct14/MacysTestLocation.csv";
//            final String csvFile = "/Users/gilad/Documents/Internal/geofence/me/me2locations.csv";
            final String csvFile = "/Users/gilad/Documents/Customers/AerLingus/geofence/AerLingusGeoFence091214.csv"; //al
            
            //final String csvFile = "/Users/gilad/Documents/Customers/Macys/Loc-Sept14/macys_store_locations.csv";
            FileReader in = new FileReader(csvFile);
            Iterable<CSVRecord> records = CSVFormat.EXCEL.withHeader().parse(in);
            int regCount =0;
            for (CSVRecord record : records) {
                regCount++;
                JSONObject entryPoint = new JSONObject();
                JSONObject exitPoint = new JSONObject();
                JSONObject entry = new JSONObject();
                JSONObject exit = new JSONObject();
                JSONObject actual = new JSONObject();
               
                //String  regionId= UUID.randomUUID().toString();
//region id is the same for eah entry and exit
//Macys:                
//region: ab2ea009-3af9-47a9-9e61-eec75c7a ,entry:aa63311c4-e57a-4faa-823f-b6df34b exit:bb63311c4-e57a-4faa-823f-b6df34b
//AerLingus                
//region: bcdea0a0-3af9-47a9-9e61-eec65c85 entry:aa73311c4-b57a-4faa-823f-b6df35a exit  : bb73311c4-b57a-4faa-823f-b6df35b
//Andrew  reg:ab3b900-3af9-47a9-9e72-eec75c7a exit:aa73344ce1-e58a-4faa-823e-c6df34a entry:bb73344ce1-e58a-4faa-823e-c6df34b
//me      reg:ab4d900-3af9-47a9-9e72-eec75c8a exit:aa82344ce1-e58a-4faa-823e-c6df34a entry:bb82344ce1-e58a-4faa-823e-c6df34b
                StringBuilder sbRegion = new StringBuilder();
                sbRegion.append("badea0a0-3af9-47a9-9e61-eec65c97");
                sbRegion.append(String.format("%04d",regCount));
                String regionId  = sbRegion.toString();

                StringBuilder sbEntry = new StringBuilder();
                sbEntry.append("aa83311c4-b57a-4faa-823f-b6df37a");
                sbEntry.append(String.format("%04d",regCount));
                String entryId  = sbEntry.toString();

                StringBuilder sbExit = new StringBuilder();
                sbExit.append("bb83311c4-b57a-4faa-823f-b6df37b");
                sbExit.append(String.format("%04d",regCount));
                String exitId  = sbExit.toString();
/*/ fake ocean location
                entry.put("latitude", points[index++].getXcor());
                entry.put("longitude", points[index++].getYcor());
                exit.put("latitude", points[index++].getXcor());
                exit.put("longitude", points[index++].getYcor());
 *///* real locations
                entry.put("latitude", Double.parseDouble(record.get("latitude")));
                entry.put("longitude", Double.parseDouble(record.get("longitude")));
                exit.put("latitude", Double.parseDouble(record.get("latitude")));
                exit.put("longitude", Double.parseDouble(record.get("longitude")));
// end real*/
                actual.put("latitude", Double.parseDouble(record.get("latitude")));
                actual.put("longitude", Double.parseDouble(record.get("longitude")));

                entryPoint.put("actual", actual);
                entryPoint.put("regionId", regionId);
                if (record.get("Track enter/exit").equalsIgnoreCase("Yes")) {
                    entryPoint.put("alwaysInclude", true);
                }
               
                exitPoint.put("actual", actual);
                exitPoint.put("regionId", regionId);
                if (record.get("Track enter/exit").equalsIgnoreCase("Yes")) {
                    exitPoint.put("alwaysInclude", true);
                }
//* set radius
                entryPoint.put("radius",Double.parseDouble(record.get("Radius")));
                exitPoint.put("radius",Double.parseDouble(record.get("Radius")));
 //       */
                for (int i = 0; i < creatorUserIds.length; i++) {
                    int creatorUserId = creatorUserIds[i];
                    int modifierId = modifierIds[i];
                    int organizationId = organizationIds[i];

                    String entryQuery = "INSERT INTO `SimpleLocationEntity` ( `id`,`creatorUserId`, `dateAdded`,`dateLastModified`,`description`, "
                            + "`lastModifiedByUserId`, `name`, `organizationId`, `city`, `country`, `formattedAddress`, `latitude`, `longitude`, `postal_code`)\n"
                            + "VALUES\n"
                            // Entry
                            + "('" + entryId + "'," + creatorUserId + ",now(),now(),'" + entryPoint.toString() 
                            + "'," + modifierId + ",'Entry for " + record.get("Location Name").replace("'", "''") + "'," + organizationId + ", '" + record.get("city").replace("'", "''") + "', '" + record.get("country").replace("'", "''") + "', '" + record.get("formatted_address").replace("'", "''") + "'," + entry.getDouble("latitude") + "," + entry.getDouble("longitude") + ", '" + record.get("zip") + "');";
//                            + "('" + UUID.randomUUID().toString() + "'," + creatorUserId + ",now(),now(),'" + entryPoint.toString() + "'," + modifierId + ",'Entry for " + record.get("Location Name").replace("'", "''") + "'," + organizationId + ", '" + record.get("city").replace("'", "''") + "', '" + record.get("country").replace("'", "''") + "', '" + record.get("formatted_address").replace("'", "''") + "'," + entry.getDouble("latitude") + "," + entry.getDouble("longitude") + ", '" + record.get("zip") + "');";


                    String exitQuery = "INSERT INTO `SimpleLocationEntity` (`id`, `creatorUserId`,`dateAdded`,`dateLastModified`, `description`, `lastModifiedByUserId`, `name`, `organizationId`, `city`, `country`, `formattedAddress`, `latitude`, `longitude`, `postal_code`)\n"
                            + "VALUES\n"
                            // Exit
                            + "('" + exitId + "'," + creatorUserId + ",now(),now(),'" + exitPoint.toString() + "'," + modifierId + ",'Exit for " + record.get("Location Name").replace("'", "''") + "'," + organizationId + ", '" + record.get("city").replace("'", "''") + "', '" + record.get("country").replace("'", "''") + "', '" + record.get("formatted_address").replace("'", "''") + "'," + exit.getDouble("latitude") + "," + exit.getDouble("longitude") + ", '" + record.get("zip") + "');";
//                            + "('" + UUID.randomUUID().toString() + "'," + creatorUserId + ",now(),now(),'" + exitPoint.toString() + "'," + modifierId + ",'Exit for " + record.get("Location Name").replace("'", "''") + "'," + organizationId + ", '" + record.get("city").replace("'", "''") + "', '" + record.get("country").replace("'", "''") + "', '" + record.get("formatted_address").replace("'", "''") + "'," + exit.getDouble("latitude") + "," + exit.getDouble("longitude") + ", '" + record.get("zip") + "');";

                    writer.println(entryQuery);
                    writer.println(exitQuery);
                    writer.println();
                }

            }

        } catch (ArrayIndexOutOfBoundsException ex) {
            System.out.println("----error reading array---" + ex.toString());
        } catch (FileNotFoundException ex) {
            System.out.println("-------exception---" + ex);
        } catch (IOException ex) {
            System.out.println("-------exception---" + ex);
        } catch (JSONException ex) {
            System.out.println("---Error json formatting---" + ex);
        } finally {
            writer.close();
        }

    }

    private static double getDecimalFormatted(double cor, int places) {
        if (places < 0) throw new IllegalArgumentException();

        BigDecimal bd = new BigDecimal(cor);
        bd = bd.setScale(places, RoundingMode.HALF_UP);
        return bd.doubleValue();
    }
}
