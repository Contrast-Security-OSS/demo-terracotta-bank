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

import org.apache.http.client.methods.RequestBuilder;
import org.testng.Assert;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.Test;

public class RegisterFunctionalTest extends AbstractEmbeddedTomcatSeleniumTest {

	@Test(groups="password")
	public void testRegister() {
		String response = attemptRegistration("tb", "4Y8j&c*bMi0evBRQ");
		Assert.assertTrue(response.contains("Welcome, Terracotta Bank!"));
	}

	private String attemptRegistration(String username, String password) {
		return http.postForContent(RequestBuilder.post("/register")
						.addParameter("registerUsername", username)
						.addParameter("registerPassword", password)
						.addParameter("registerName", "Terracotta Bank")
						.addParameter("registerEmail", username + "@peartree.com"));
	}
}
