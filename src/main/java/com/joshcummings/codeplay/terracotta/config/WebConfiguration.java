/*
 * Copyright 2015-2019 Josh Cummings
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
package com.joshcummings.codeplay.terracotta.config;

import com.joshcummings.codeplay.terracotta.app.ContentParsingFilter;
import com.joshcummings.codeplay.terracotta.app.DecryptionFilter;
import com.joshcummings.codeplay.terracotta.app.RequestLogFilter;
import com.joshcummings.codeplay.terracotta.app.UserFilter;
import com.joshcummings.codeplay.terracotta.metrics.RequestClassificationFilter;
import com.joshcummings.codeplay.terracotta.service.*;
import com.joshcummings.codeplay.terracotta.servlet.*;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.boot.web.servlet.ServletContextInitializer;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.servlet.DispatcherType;
import javax.servlet.MultipartConfigElement;
import javax.servlet.Servlet;
import javax.servlet.annotation.MultipartConfig;
import java.util.Arrays;
import java.util.EnumSet;

import static javax.servlet.DispatcherType.REQUEST;
import static javax.servlet.SessionTrackingMode.COOKIE;
import static javax.servlet.SessionTrackingMode.URL;

@Configuration
public class WebConfiguration implements WebMvcConfigurer {

	@Bean
	public WebServerFactoryCustomizer<TomcatServletWebServerFactory> containerCustomizer() {
		return container -> {
			container.addContextCustomizers(
					tomcat -> tomcat.setUseHttpOnly(false));
		};
	}

	@Bean
	ServletContextInitializer urlSessionTracking() {
		return servletContext -> servletContext.setSessionTrackingModes(
				EnumSet.of(URL, COOKIE));
	}

	@Bean
	public FilterRegistrationBean<DecryptionFilter> decryptionFilter() {
		FilterRegistrationBean<DecryptionFilter> bean = new FilterRegistrationBean<>();
		bean.setFilter(new DecryptionFilter());
		bean.setOrder(-2);
		bean.setDispatcherTypes(EnumSet.of(REQUEST));
		return bean;
	}

	@Bean
	public FilterRegistrationBean<ContentParsingFilter> contentFilter() {
		FilterRegistrationBean<ContentParsingFilter> bean = new FilterRegistrationBean<>();
		bean.setFilter(new ContentParsingFilter());
		bean.setOrder(-1);
		bean.setDispatcherTypes(EnumSet.of(REQUEST));
		return bean;
	}

	@Bean
	public FilterRegistrationBean<UserFilter> userFilter(AccountService accountService, UserService userService) {
		FilterRegistrationBean<UserFilter> bean = new FilterRegistrationBean<>();
		bean.setFilter(new UserFilter(accountService, userService));
		bean.setOrder(0);
		return bean;
	}

	@Bean
	public FilterRegistrationBean<RequestLogFilter> requestFilter() {
		FilterRegistrationBean<RequestLogFilter> bean = new FilterRegistrationBean<>();
		bean.setFilter(new RequestLogFilter());
		bean.setOrder(1);
		return bean;
	}

	@Bean
	public FilterRegistrationBean<RequestClassificationFilter> requestClassificationFilter() {
		FilterRegistrationBean<RequestClassificationFilter> bean = new FilterRegistrationBean<>();
		bean.setFilter(new RequestClassificationFilter());
		bean.setDispatcherTypes(REQUEST, DispatcherType.FORWARD, DispatcherType.ERROR);
		return bean;
	}

	@Bean
	public ServletRegistrationBean<ErrorServlet> errorServlet() {
		return this.servlet(new ErrorServlet(), "/error");
	}

	@Bean
	public ServletRegistrationBean<AccountServlet> accountsServlet(AccountService accountService) {
		return this.servlet(new AccountServlet(accountService), "/showAccounts");
	}

	@Bean
	public ServletRegistrationBean<AdminLoginServlet> adminLoginServlet(AccountService accountService,
			UserService userService) {
		return this.servlet(new AdminLoginServlet(), "/adminLogin");
	}

	@Bean
	public ServletRegistrationBean<BankTransferServlet> bankTransferServlet(AccountService accountService,
			ClientService clientService) {
		return this.servlet(new BankTransferServlet(accountService, clientService), "/bankTransfer");
	}

	@Bean
	public ServletRegistrationBean<ChangePasswordServlet> changePasswordServlet(UserService userService) {
		return this.servlet(new ChangePasswordServlet(userService), "/changePassword");
	}

	@Bean
	public ServletRegistrationBean<CheckLookupServlet> checkLookupServlet(CheckService checkService) {
		return this.servlet(new CheckLookupServlet(checkService), "/checkLookup");
	}

	@Bean
	public ServletRegistrationBean<ContactUsServlet> contactUsServlet(MessageService messageService) {
		return this.servlet(new ContactUsServlet(messageService), "/contactus");
	}

	@Bean
	public ServletRegistrationBean<EmployeeLoginServlet> employeeLoginServlet(UserService userService) {
		return this.servlet(new EmployeeLoginServlet(userService), "/employeeLogin");
	}

	@Bean
	public ServletRegistrationBean<ForgotPasswordServlet> forgotPasswordServlet(UserService userService) {
		return this.servlet(new ForgotPasswordServlet(userService), "/forgotPassword");
	}

	@Bean
	public ServletRegistrationBean<LoginServlet> loginServlet(AccountService accountService, UserService userService) {
		return this.servlet(new LoginServlet(accountService, userService), "/login");
	}

	@Bean
	public ServletRegistrationBean<LogoutServlet> logoutServlet() {
		return this.servlet(new LogoutServlet(), "/logout");
	}

	@Bean
	public ServletRegistrationBean<MakeDepositServlet> makeDepositServlet(AccountService accountService,
			CheckService checkService) {
		ServletRegistrationBean<MakeDepositServlet> bean = this.servlet(
				new MakeDepositServlet(accountService, checkService), "/makeDeposit");

		MultipartConfigElement element = new MultipartConfigElement(
				MakeDepositServlet.class.getAnnotation(MultipartConfig.class));

		bean.setMultipartConfig(element);

		return bean;
	}

	@Bean
	public ServletRegistrationBean<MessagesServlet> messagesServlet(MessageService messageService) {
		return this.servlet(new MessagesServlet(messageService), "/showMessages");
	}

	@Bean
	public ServletRegistrationBean<RegisterServlet> registerServlet(AccountService accountService,
			UserService userService) {
		return this.servlet(new RegisterServlet(accountService, userService), "/register");
	}

	@Bean
	public ServletRegistrationBean<SiteStatisticsServlet> siteStatisticsServlet(AccountService accountService,
			UserService userService) {
		return this.servlet(new SiteStatisticsServlet(accountService, userService), "/siteStatistics");
	}

	@Bean
	public ServletRegistrationBean<TransferMoneyServlet> transferMoneyServlet(AccountService accountService) {
		return this.servlet(new TransferMoneyServlet(accountService), "/transferMoney");
	}

	@Override
	public void addViewControllers(ViewControllerRegistry registry) {
		registry.addViewController("/").setViewName("forward:/index.jsp");
		registry.setOrder(Ordered.HIGHEST_PRECEDENCE);
	}

	private <T extends Servlet> ServletRegistrationBean<T> servlet(T servlet, String urlMapping) {
		ServletRegistrationBean<T> bean = new ServletRegistrationBean<>();
		bean.setServlet(servlet);
		bean.setUrlMappings(Arrays.asList(urlMapping));
		return bean;
	}
}