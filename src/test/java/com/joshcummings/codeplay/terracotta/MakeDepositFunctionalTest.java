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
import org.testng.annotations.*;
import java.io.*;

public class MakeDepositFunctionalTest extends AbstractEmbeddedTomcatSeleniumTest {
	@BeforeClass(alwaysRun = true)
	public void doLogin() {
		login("john.coltraine", "j0hn");
	}

	@AfterClass(alwaysRun = true)
	public void doLogout() {
		logout();
	}

	@Test(groups = "web")
	public void testMakeDeposit() {
		goToPage("/");

		driver.findElement(By.name("depositAccountNumber")).sendKeys("987654321");
		driver.findElement(By.name("depositCheckNumber")).sendKeys("123");
		driver.findElement(By.name("depositAmount")).sendKeys("10");
		driver.findElement(By.name("depositCheckImage")).sendKeys(new File("src/test/resources/check.png").getAbsolutePath());

		driver.findElement(By.name("deposit")).submit();

	}

}
