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

import org.openqa.selenium.*;

import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;


public class AdminLookupCheckFunctionalTest extends AbstractEmbeddedTomcatSeleniumTest {
	@BeforeClass(alwaysRun=true)
	protected void doLogin() {
		employeeLogin("admin", "admin");
	}
	
	@AfterClass(alwaysRun=true)
	protected void doLogout() {
		logout();
	}
	
	@Test(groups="web")
	public void testLookup() throws InterruptedException {
		goToPage("/employee.jsp");

		findElementEventually(driver, By.name("checkLookupNumber"), 2000).sendKeys("123");
		driver.findElement(By.name("checkLookupNumber")).submit();


		Thread.sleep(2000);

		String s = driver.findElement(By.cssSelector("#lookup > div.messages")).getText();

		Assert.assertEquals(s, "Bad Request");

	}
}
