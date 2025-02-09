package com.joshcummings.codeplay.terracotta;

import com.joshcummings.codeplay.terracotta.testng.DockerSupport;
import com.joshcummings.codeplay.terracotta.http.HttpSupport;
import com.joshcummings.codeplay.terracotta.testng.TomcatSupport;

import org.testng.ITestContext;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;

import org.springframework.context.ApplicationContext;

import static org.apache.http.client.methods.RequestBuilder.post;

public class AbstractEmbeddedTomcatTest {
	protected TomcatSupport tomcat = new TomcatSupport();
	protected DockerSupport docker = new DockerSupport();
	protected HttpSupport http = new HttpSupport();

	protected ApplicationContext context;

	@BeforeTest(alwaysRun=true)
	public void start(ITestContext ctx) throws Exception {
		if ( "docker".equals(ctx.getName()) ) {
			docker().startContainer();
		} else {
			context = tomcat.startContainer();
		}
	}

	@AfterTest(alwaysRun=true)
	public void stop(ITestContext ctx) throws Exception {
		if ( "docker".equals(ctx.getName()) ) {
			docker().stopContainer();
		} else {
			tomcat.stopContainer();
		}
	}

	protected DockerSupport docker() {
		return docker == null ? ( docker = new DockerSupport() ) : docker;
	}

	protected String login(String username, String password) {
		return http.postForContent(post("/login")
				.addParameter("username", username)
				.addParameter("password", password));
	}

	protected void logout() {
		http.postForContent(post("/logout"));
	}
}
