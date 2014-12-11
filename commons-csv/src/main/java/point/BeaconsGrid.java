package point;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.UUID;

/*
 *
 * This program creates 6400 ocean points and saves in a data structure.
 * It reads csv file and creates sql insert statements for Simple Location Entity
 * Output : sql insert statements for entry, dwell, exit with dwell, exit without dwell
 * Output gets written to output.txt file
 *
 */

public class BeaconsGrid {

    public static void main(String[] args) {

        PrintWriter writer = null;
        try {

            int x, y;
            double xcor, ycor;
            Point[] points = new Point[6400];
            int index = 0;
            for (x = 0, xcor = -59.355596; x < 80; x++) {
                System.out.println();
                System.out.println();
                for (y = 0, ycor = -98.492432; y < 80; y++) {

                    ycor = ycor - 0.3;

                    points[index] = new Point(getDecimalFormatted(xcor, 6), getDecimalFormatted(ycor, 6));
                    //System.out.println(index + " : " + points[index]);
                    index++;

                }
                xcor = xcor + 0.3;
            }
            int[] creatorUserIds = {218849};
            int[] modifierIds = {218849};
            int[] organizationIds = {218856};
            index = 0;

            writer = new PrintWriter("greenwheels-output.txt", "UTF-8");
            final String csvFile = "/Users/gilad/Documents/Customers/IBM/Greenwheels/Greenwheelsbeacons.csv";
            FileReader in = new FileReader(csvFile);
            Iterable<CSVRecord> records = CSVFormat.EXCEL.withHeader().parse(in);

            for (CSVRecord record : records) {

                JSONObject entryPoint = new JSONObject();
                JSONObject exitWithDwellPoint = new JSONObject();
                JSONObject exitWithoutDwellPoint = new JSONObject();
                JSONObject dwellPoint = new JSONObject();

                JSONObject entry = new JSONObject();
                JSONObject exitWithDwell = new JSONObject();
                JSONObject exitWithoutDwell = new JSONObject();
                JSONObject dwell = new JSONObject();

                JSONObject actual = new JSONObject();
                String regionId = UUID.randomUUID().toString();
                Integer dwellDuration = null;

                if (record.get("dwell duration in sec")!= null) {
                    //dwellPoint.put("dwell", Integer.parseInt(record.get("dwell duration in sec")));
                     dwellDuration = Integer.parseInt(record.get("dwell duration in sec"));
                }

                entry.put("latitude", points[index++].getXcor());
                entry.put("longitude", points[index++].getYcor());

                exitWithDwell.put("latitude", points[index++].getXcor());
                exitWithDwell.put("longitude", points[index++].getYcor());

                exitWithoutDwell.put("latitude", points[index++].getXcor());
                exitWithoutDwell.put("longitude", points[index++].getYcor());

                dwell.put("latitude", points[index++].getXcor());
                dwell.put("longitude", points[index++].getYcor());

                actual.put("major", Integer.parseInt(record.get("major")));
                actual.put("minor", Integer.parseInt(record.get("minor")));

                entryPoint.put("actual", actual);
                entryPoint.put("beaconRegionId", regionId);
                if (record.get("Track enter/exit").equalsIgnoreCase("Yes")) {
                    entryPoint.put("alwaysInclude", true);
                }
                if(dwellDuration != null){
                    entryPoint.put("dwell", dwellDuration);
                }

                exitWithDwellPoint.put("actual", actual);
                exitWithDwellPoint.put("beaconRegionId", regionId);
                if (record.get("Track enter/exit").equalsIgnoreCase("Yes")) {
                    exitWithDwellPoint.put("alwaysInclude", true);
                }
                if(dwellDuration != null){
                    exitWithDwellPoint.put("dwell", dwellDuration);
                }

                exitWithoutDwellPoint.put("actual", actual);
                exitWithoutDwellPoint.put("beaconRegionId", regionId);
                if (record.get("Track enter/exit").equalsIgnoreCase("Yes")) {
                    exitWithoutDwellPoint.put("alwaysInclude", true);
                }
                if(dwellDuration != null){
                    exitWithoutDwellPoint.put("dwell", dwellDuration);
                }

                dwellPoint.put("actual", actual);
                dwellPoint.put("beaconRegionId", regionId);
                if (record.get("Track enter/exit").equalsIgnoreCase("Yes")) {
                    dwellPoint.put("alwaysInclude", true);
                }
                if(dwellDuration != null){
                    dwellPoint.put("dwell", dwellDuration);
                }


                for (int i = 0; i < creatorUserIds.length; i++) {
                    int creatorUserId = creatorUserIds[i];
                    int modifierId = modifierIds[i];
                    int organizationId = organizationIds[i];

                    String entryQuery = "INSERT INTO `SimpleLocationEntity` ( `id`,`creatorUserId`, `dateAdded`,`dateLastModified`,`description`, `lastModifiedByUserId`, `name`, `organizationId`, `city`, `country`, `formattedAddress`, `latitude`, `longitude`, `postal_code`)\n"
                            + "VALUES\n"
                            + "('" + UUID.randomUUID().toString() + "'," + creatorUserId + ",now(),now(),'" + entryPoint.toString() + "'," + modifierId + ",'Entry for " + record.get("Location Name").replace("'", "''") + "'," + organizationId + ", '" + record.get("city").replace("'", "''") + "', '" + record.get("country").replace("'", "''") + "', '" + record.get("formatted_address").replace("'", "''") + "'," + entry.getDouble("latitude") + "," + entry.getDouble("longitude") + ", '" + record.get("zip") + "');";


                    String exitWithDwellQuery = "INSERT INTO `SimpleLocationEntity` (`id`, `creatorUserId`,`dateAdded`,`dateLastModified`, `description`, `lastModifiedByUserId`, `name`, `organizationId`, `city`, `country`, `formattedAddress`, `latitude`, `longitude`, `postal_code`)\n"
                            + "VALUES\n"
                            + "('" + UUID.randomUUID().toString() + "'," + creatorUserId + ",now(),now(),'" + exitWithDwellPoint.toString() + "'," + modifierId + ",'Exit with dwell for " + record.get("Location Name").replace("'", "''") + "'," + organizationId + ", '" + record.get("city").replace("'", "''") + "', '" + record.get("country").replace("'", "''") + "', '" + record.get("formatted_address").replace("'", "''") + "'," + exitWithDwell.getDouble("latitude") + "," + exitWithDwell.getDouble("longitude") + ", '" + record.get("zip") + "');";

                    String exitWithoutDwellQuery = "INSERT INTO `SimpleLocationEntity` (`id`, `creatorUserId`,`dateAdded`,`dateLastModified`, `description`, `lastModifiedByUserId`, `name`, `organizationId`, `city`, `country`, `formattedAddress`, `latitude`, `longitude`, `postal_code`)\n"
                            + "VALUES\n"
                            + "('" + UUID.randomUUID().toString() + "'," + creatorUserId + ",now(),now(),'" + exitWithoutDwellPoint.toString() + "'," + modifierId + ",'Exit without dwell for " + record.get("Location Name").replace("'", "''") + "'," + organizationId + ", '" + record.get("city").replace("'", "''") + "', '" + record.get("country").replace("'", "''") + "', '" + record.get("formatted_address").replace("'", "''") + "'," + exitWithoutDwell.getDouble("latitude") + "," + exitWithoutDwell.getDouble("longitude") + ", '" + record.get("zip") + "');";


                    String dwellQuery = "INSERT INTO `SimpleLocationEntity` (`id`, `creatorUserId`,`dateAdded`,`dateLastModified`, `description`, `lastModifiedByUserId`, `name`, `organizationId`, `city`, `country`, `formattedAddress`, `latitude`, `longitude`, `postal_code`)\n"
                            + "VALUES\n"
                            + "('" + UUID.randomUUID().toString() + "'," + creatorUserId + ",now(),now(),'" + dwellPoint.toString() + "'," + modifierId + ",'Dwell for " + record.get("Location Name").replace("'", "''") + "'," + organizationId + ", '" + record.get("city").replace("'", "''") + "', '" + record.get("country").replace("'", "''") + "', '" + record.get("formatted_address").replace("'", "''") + "'," + dwell.getDouble("latitude") + "," + dwell.getDouble("longitude") + ", '" + record.get("zip") + "');";


                    writer.println(entryQuery);
                    writer.println(exitWithDwellQuery);
                    writer.println(exitWithoutDwellQuery);
                    writer.println(dwellQuery);
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
