/*
 * Copyright 2015-2018 Josh Cummings
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.joshcummings.codeplay.terracotta;

import com.google.gson.Gson;
import com.joshcummings.codeplay.terracotta.model.Account;
import com.joshcummings.codeplay.terracotta.model.Client;
import com.joshcummings.codeplay.terracotta.service.AccountService;
import org.apache.http.client.methods.RequestBuilder;
import org.testng.annotations.Test;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.net.URI;
import java.security.KeyFactory;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

import static java.nio.charset.StandardCharsets.UTF_8;
import static org.junit.Assert.assertEquals;

/**
 * @author Josh Cummings
 */
public class BankTransferFunctionalTest extends AbstractEmbeddedTomcatSeleniumTest {
	AccountService accountService;

	Account account = new Account("0", new BigDecimal("25"), 98L, "0");
	Client v1Client = new Client("00", "12341234", secretKey(), Client.Algorithm.v1, URI.create("http://localhost:8081/.well-known/jwks.json"));
	Client v2Client = new Client("01", "43214321", publicKey(), Client.Algorithm.v2, URI.create("http://localhost:8081/.well-known/jwks.json"));

	Gson gson = new Gson();


	@Test(groups="web")
	public void testUnsignedBankTransfer() throws Exception {
		int status = http.postForStatus(RequestBuilder.post("/bankTransfer")
				.addParameter("clientId", this.v1Client.getClientId())
				.addParameter("accountNumber", String.valueOf(this.account.getNumber()))
				.addParameter("amount", "92.00"));

		assertEquals(status, 200);
	}

	private static SecretKey secretKey() {
		byte[] bytes = Base64.getDecoder().decode("fYJE4bObiVAbhseUTXaRkg==".getBytes(UTF_8));
		return new SecretKeySpec(bytes, "AES");
	}

	private static RSAPublicKey publicKey() {
		try {
			byte[] bytes = Base64.getDecoder().decode("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtWO9vMYnCtL55JKSAkPLVZ8EzAcpSoNSM42UBdcaoZUks8SYQMYrshQmrcYB6RNcqglJX9EWCeD14y6nt5cTEsW6UAabZD/7Qj1tyJm50KA3UFwDov3n4xwtph5EAbLxw/DiFt6rN3kXwDiuzjuWg9ShmoxeE3LTTLVy/B+WP5YfeXoSOrGHTj/hpexDG5pYUIFPoDb79LzzBbghpQ3Pvwg1lkKAnL1OYLkv66V24DIBv/LeqGTGT95TpTdRpQpp2RvhopzntP88EyGJf3mRXq9TQ5isHypbvKuimBwE2Ww3Un9vu+HBn8p3n4P3TDcOxOVeAGtALUdflGaHJbNhIQIDAQAB");
			return (RSAPublicKey) KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(bytes));
		} catch ( Exception e ) {
			throw new IllegalArgumentException(e);
		}
	}
}
