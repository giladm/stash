/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package apnscert;

import java.io.FileReader;
import java.util.Date;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.Arrays;

/**
 *
 * @author leszektumm
 */
public class ApnsCert {

    private String filePath;
    private byte[] cert;
    private Date certificateExpirationDate;

    public Object encode(Object value) {
        String apnsCert = null;

        ApnsCertificateBytes apnsCertificateBytes = (ApnsCertificateBytes) value;

        if (apnsCertificateBytes != null) {
            apnsCert = apnsCertificateBytes.asString();
        }
        System.out.println(apnsCert);
        return apnsCert;
    }

    public Object decode(Object fromDBObject) {
        final String base64Certificate = (String) fromDBObject;
        ApnsCertificateBytes apnsCertificateBytes = null;

        if (base64Certificate == null) {
            return null;
        }
        try {
            apnsCertificateBytes = ApnsCertificateBytes.validate(base64Certificate);
        } catch (Exception ex) {
        }

        return apnsCertificateBytes;
    }

    /**
     * @param args the command line arguments
     */
    ApnsCert(String file) {
        filePath = file;
    }

    public static void main(String[] args) {
        ApnsCert ac = new ApnsCert(args[0]);
        Path path = Paths.get(args[0]);
        Path path2 = Paths.get(args[1]);
        try {
            ac.cert = Files.readAllBytes(path);
            String str = new String(ac.cert, StandardCharsets.US_ASCII);
            ApnsCertificateBytes outputBytes = (ApnsCertificateBytes) ac.decode(str);
            Files.write(path2, outputBytes.asBytes(), StandardOpenOption.CREATE);
        } catch (IOException ex) {

        }
    }

}
