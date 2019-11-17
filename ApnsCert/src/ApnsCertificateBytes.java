/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package apnscert;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.Serializable;
import java.util.Date;
import org.apache.commons.codec.binary.Base64;
/**
 *
 * @author leszektumm
 */
public class ApnsCertificateBytes implements Serializable {

    private byte[] cert;
    private Date certificateExpirationDate;

    protected ApnsCertificateBytes() {
    }

    public ApnsCertificateBytes(byte[] cert) {
        this.cert = cert;
    }

    public ApnsCertificateBytes(byte[] cert, Date certificateExpirationDate) {
        this.cert = cert;
        this.certificateExpirationDate = certificateExpirationDate;
    }

    // We expose a static method to instantiate new instances so developers are forced to write
    // ApnsCertificateBytes.generateNew(...). This method and ApnsCertificateBytes.validate(String stringCert)
    // should be the developers' only two means of creating an ApnsCertificate object.
    public static ApnsCertificateBytes generateNew(byte[] cert)throws Exception {
        return ApnsCertificateBytes.validate(cert);
    }

    public static ApnsCertificateBytes validate(byte[] cert) throws Exception {
        if (cert.length == 0) {
            throw new Exception("APNs Certificate cannot be empty");
        }
        return new ApnsCertificateBytes(cert);
    }

    public static ApnsCertificateBytes validate(String stringCert) throws Exception {
        return new ApnsCertificateBytes(Base64.decodeBase64(stringCert));
    }

    public byte[] asBytes() {
        return cert;
    }

    public String asString() {
        return Base64.encodeBase64URLSafeString(cert);
    }

    public String asAbridgedString() {
        String apnsCertificateAsString = asString();
        return apnsCertificateAsString.substring(0, 10) + "..." + apnsCertificateAsString.substring(apnsCertificateAsString.length() - 9);
    }

    public InputStream asInputStream() {
        return new ByteArrayInputStream(asBytes());
    }

    public Date getCertificateExpirationDate() {
        return certificateExpirationDate;
    }

    public void setCertificateExpirationDate(Date certificateExpirationDate) {
        this.certificateExpirationDate = certificateExpirationDate;
    }
}
