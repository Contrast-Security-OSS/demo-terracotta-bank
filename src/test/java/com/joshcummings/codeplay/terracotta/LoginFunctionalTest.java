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

import org.openqa.selenium.By;
import org.testng.Assert;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.Test;

import static org.apache.http.client.methods.RequestBuilder.post;

public class LoginFunctionalTest extends AbstractEmbeddedTomcatSeleniumTest {
	@AfterMethod(alwaysRun=true)
	public void doLogout() {
		logout();
	}

	@Test(groups="web")
	public void testLoginNoPassword() throws InterruptedException {

		String content = http.postForContent(post("/login")
				.addParameter("username", "admin")
				.addParameter("password", "blah"));

		Assert.assertTrue(content.contains("provided is incorrect"));
	}

	@Test(groups="data")
	public void testValidLogin() {
		String content = http.postForContent(post("/login")
				.addParameter("username", "admin")
				.addParameter("password", "admin"));

		Assert.assertTrue(content.contains("Welcome, Admin Admin!"));
	}

	@Test(groups="http")
	public void testLoginRedirect() throws InterruptedException {
		goToPage("/?relay=http://honestsite.com/");

		driver.findElement(By.name("username")).sendKeys("admin");
		driver.findElement(By.name("password")).sendKeys("admin");
		driver.findElement(By.name("login")).submit();

		Thread.sleep(2000);

		Assert.assertEquals(driver.getCurrentUrl(), "http://honestsite.com/", "You got redirected to: " + driver.getCurrentUrl());
	}
}
