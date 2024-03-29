import static net.grinder.script.Grinder.grinder
import static org.junit.Assert.*
import static org.hamcrest.Matchers.*
import net.grinder.plugin.http.HTTPRequest
import net.grinder.plugin.http.HTTPPluginControl
import net.grinder.script.GTest
import net.grinder.script.Grinder
import net.grinder.scriptengine.groovy.junit.GrinderRunner
import net.grinder.scriptengine.groovy.junit.annotation.BeforeProcess
import net.grinder.scriptengine.groovy.junit.annotation.BeforeThread
// import static net.grinder.util.GrinderUtils.* // You can use this if you're using nGrinder after 3.2.3
import org.junit.Before
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith

import java.util.Date
import java.util.List
import java.util.ArrayList

import HTTPClient.Cookie
import HTTPClient.CookieModule
import HTTPClient.HTTPResponse
import HTTPClient.NVPair

import groovy.json.JsonSlurper

/**
 * A simple example using the HTTP plugin that shows the retrieval of a
 * single page via HTTP. 
 * 
 * This script is automatically generated by ngrinder.
 * 
 * @author admin
 */
@RunWith(GrinderRunner)
class TestRunner {

	public static GTest test
	public static HTTPRequest request
	public static NVPair[] headers = []
	public static NVPair[] params = []
	public static Cookie[] cookies = []
	public static String token;

	@BeforeProcess
	public static void beforeProcess() {
		HTTPPluginControl.getConnectionDefaults().timeout = 6000
		test = new GTest(1, "http://35.222.10.15:4000/users")
		request = new HTTPRequest()
		// Set header datas
		List<NVPair> headerList = new ArrayList<NVPair>()
		headerList.add(new NVPair("Content-Type", "application/x-www-form-urlencoded"))
		headers = headerList.toArray()
		//set param data
		List<NVPair> paramList = new ArrayList<NVPair>()
		paramList.add(new NVPair("username", "Jim"))
		paramList.add(new NVPair("orgName", "Org1"))
		params = paramList.toArray()
		grinder.logger.info("before process.");
		
	}

	@BeforeThread 
	public void beforeThread() {
		test.record(this, "test")
		grinder.statistics.delayReports=true;
		grinder.logger.info("before thread.");
		
		HTTPResponse result = request.POST("http://35.222.10.15:4000/users", params)

		if (result.statusCode == 301 || result.statusCode == 302) {
			grinder.logger.warn("Warning. The response may not be correct. The response code was {}.", result.statusCode); 
		} else {
			assertThat(result.statusCode, is(200));
			//println result.getText()
			def jsonMsg = new JsonSlurper().parseText(result.getText())
			//println jsonMsg.token
			token = jsonMsg.token
		}
		
		//set header for json
		List<NVPair> headerList = new ArrayList<NVPair>()
		headerList.add(new NVPair("Content-Type", "application/json"))
		headerList.add(new NVPair("authorization", "Bearer " + token))
		headers = headerList.toArray()
		request.setHeaders(headers)
		
	}
	
	@Before
	public void before() {
		request.setHeaders(headers)
		cookies.each { CookieModule.addCookie(it, HTTPPluginControl.getThreadHTTPClientContext()) }
		grinder.logger.info("before thread. init headers and cookies");
		

	}

	@Test
	public void test(){
        String threadNumber = Integer.toString(grinder.agentNumber) + Integer.toString(grinder.processNumber) + Integer.toString(grinder.threadNumber);
        String key1 = "a" + threadNumber;
        String key2 = "b" + threadNumber;
		
        // Test
        APITestSet(key1, "1000")
        APITestSet(key2, "1000")
        APITestMove(key1, key2)
        APITestSwap(key1, key2)
        APITestQuery(key1)
        APITestQuery(key2)
	}

    def APITestMove(key1, key2) {
        // Test move
        def reqBody = '{"peers": ["peer0.org1.example.com","peer0.org2.example.com"], "fcn":"move", "args":["'+key1+'","'+key2+'","10"]}';
		HTTPResponse result = request.POST("http://35.222.10.15:4000/channels/mychannel/chaincodes/mycc", reqBody.getBytes())
		
		if (result.statusCode == 301 || result.statusCode == 302) {
			grinder.logger.warn("Warning. The response may not be correct. The response code was {}.", result.statusCode); 
		} else {
			assertThat(result.statusCode, is(200));
            println result.getText()
		}
    }

    def APITestSwap(key1, key2) {
        def reqBody = '{"peers": ["peer0.org1.example.com","peer0.org2.example.com"], "fcn":"swap", "args":["'+key1+'","'+key2+'"]}';
		HTTPResponse result = request.POST("http://35.222.10.15:4000/channels/mychannel/chaincodes/mycc", reqBody.getBytes())
		
		if (result.statusCode == 301 || result.statusCode == 302) {
			grinder.logger.warn("Warning. The response may not be correct. The response code was {}.", result.statusCode); 
		} else {
			assertThat(result.statusCode, is(200));
            println result.getText()
		}
    }

    def APITestSet(key, amount) {
        // Test Set
        def reqBody = '{"peers": ["peer0.org1.example.com","peer0.org2.example.com"], "fcn":"set", "args":["'+key+'","'+amount+'"]}';
		HTTPResponse result = request.POST("http://35.222.10.15:4000/channels/mychannel/chaincodes/mycc", reqBody.getBytes())

		if (result.statusCode == 301 || result.statusCode == 302) {
			grinder.logger.warn("Warning. The response may not be correct. The response code was {}.", result.statusCode); 
		} else {
			assertThat(result.statusCode, is(200));
            println result.getText()
		}
    }

    def APITestQuery(key) {
        // Test query
		HTTPResponse result = request.GET("http://35.222.10.15:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22"+key+"%22%5D")
		if (result.statusCode == 301 || result.statusCode == 302) {
			grinder.logger.warn("Warning. The response may not be correct. The response code was {}.", result.statusCode); 
		} else {
			assertThat(result.statusCode, is(200));
            println result.getText()
		}
    }

}
