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
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import java.io.File;

public class ChangePasswordFunctionalTest extends AbstractEmbeddedTomcatSeleniumTest {
	@BeforeClass(alwaysRun = true)
	public void doLogin() {
		login("john.coltraine", "j0hn");
	}

	@AfterClass(alwaysRun = true)
	public void doLogout() {
		logout();
	}

	@Test(groups = "web")
	public void changePassword() throws InterruptedException {
		goToPage("/");

		driver.findElement(By.name("changePassword")).sendKeys("123");
		driver.findElement(By.name("verifyChangePassword")).sendKeys("123");
		driver.findElement(By.name("changePassword")).submit();

		Thread.sleep(5000);

		String s = driver.findElement(By.cssSelector("#change > div.messages")).getText();

		Assert.assertTrue(s.contains("Your password (123) isn't strong enough"));
	}

}
