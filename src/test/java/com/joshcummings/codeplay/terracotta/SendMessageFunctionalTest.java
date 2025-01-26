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

public class SendMessageFunctionalTest extends AbstractEmbeddedTomcatSeleniumTest {

	@AfterMethod(alwaysRun=true)
	public void doLogout() {
		logout();
	}


	@Test(groups="messages")
	public void sendMessage() throws InterruptedException {
		goToPage("/");

		driver.findElement(By.name("contactName")).sendKeys("Terracotta Bank");
		driver.findElement(By.name("contactEmail")).sendKeys("tb@peartree.com");
		driver.findElement(By.name("contactSubject")).sendKeys("Enquiry");
		driver.findElement(By.name("contactMessage")).sendKeys("Do you use premium clay?");
		driver.findElement(By.name("contactName")).submit();

		Thread.sleep(10000);

		String s = driver.findElement(By.cssSelector("#contact div.messages")).getText();

		Assert.assertEquals(s, "Delivered!");
	}
}
