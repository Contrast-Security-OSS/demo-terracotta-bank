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
import org.testng.annotations.AfterMethod;
import org.testng.annotations.Test;

import static org.apache.http.client.methods.RequestBuilder.post;

public class AdminLoginFunctionalTest extends AbstractEmbeddedTomcatSeleniumTest {
    @AfterMethod(alwaysRun=true)
    public void doLogout() {
        logout();
    }

    @Test(groups="data")
    public void testValidLogin() {
        String content = http.postForContent(post("/adminLogin")
                .addParameter("username", "admin")
                .addParameter("password", "backoffice"));

        Assert.assertTrue(content.contains("Welcome, system."));
    }

    @Test(groups="data")
    public void testLoginPage() {
        goToPage("/adminLogin");

        // Find the username and password input fields
        WebElement usernameField = driver.findElement(By.name("username"));
        WebElement passwordField = driver.findElement(By.name("password"));

        // Assert that the username and password fields exist
        Assert.assertNotNull(usernameField);
        Assert.assertNotNull(passwordField);
    }

}
