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
import org.openqa.selenium.WebElement;
import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

public class TransferMoneyFunctionalTest extends AbstractEmbeddedTomcatSeleniumTest {
	@BeforeClass(alwaysRun=true)
	public void doLogin(ITestContext ctx) {
		System.out.println("Logging in b4 trying to transfer money");
		login("john.coltraine", "j0hn");
	}

	@AfterClass(alwaysRun=true)
	public void doLogout() {
		System.out.println("Logging out After trying to transfer money");
		logout();
	}
	
	@Test(groups="web")
	public void testTransferMoney() throws InterruptedException {
		goToPage("/");

		driver.findElement(By.name("toAccountNumber")).sendKeys("987654321");
		driver.findElement(By.name("transferAmount")).sendKeys("10");
		driver.findElement(By.name("transfer")).submit();

		Thread.sleep(5000);

		String s = driver.findElement(By.cssSelector("#transfer > div.messages")).getText();

		Assert.assertEquals(s, "Transferred!");
	}

	@Test(groups="web")
	public void testLookupCheck() throws InterruptedException {
		goToPage("/");

		findElementEventually(driver, By.name("checkLookupNumber"), 2000).sendKeys("456");
		driver.findElement(By.name("checkLookupNumber")).submit();


		Thread.sleep(2000);

		String s = driver.findElement(By.cssSelector("#lookup > div.messages")).getText();

		Assert.assertEquals(s, "Bad Request");
	}
}
