package org.bigbluebutton.deskShare;

import java.util.List;

import org.red5.logging.Red5LoggerFactory;
import org.red5.server.adapter.MultiThreadedApplicationAdapter;
import org.red5.server.api.IBandwidthConfigure;
import org.red5.server.api.IConnection;
import org.red5.server.api.IScope;
import org.red5.server.api.Red5;
import org.red5.server.api.stream.IServerStream;
import org.red5.server.api.stream.IStreamCapableConnection;
import org.red5.server.api.stream.support.SimpleConnectionBWConfig;

import org.slf4j.Logger;

/**
 * The Application class is the main class of the deskShare server side
 * @author Snap
 *
 */
public class Application extends MultiThreadedApplicationAdapter {
	private static Logger log = Red5LoggerFactory.getLogger(Application.class, "deskShare");
	
	private IScope appScope;
	private IServerStream serverStream;
	
	private ClientProxy clientProxy;
	private Red5Streamer streamPublisher;
	private VideoSaver streamRecorder;
	
	{
		log.info("deskShare created");
		System.out.println("deskShare created");
	}
	
	public void init(){
		
	}
	
	/**
	 * Runs when the application is first started. Sets up relevant objects to listen to the deskShare client
	 * and publish the stream on red5
	 */
	public boolean appStart(IScope app){
		log.info("deskShare appStart");
		System.out.println("deskShare appStart");
		appScope = app;
		
		clientProxy = new ClientProxy(app);
		Thread clientThread = new Thread(clientProxy);
		clientThread.start();
		
		return true;
	}
	
	public boolean appConnect(IConnection conn, Object[] params){
		log.info("deskShare appConnect");
		System.out.println("deskShare appConnect");
		measureBandwidth(conn);
		
		if (conn instanceof IStreamCapableConnection){
			IStreamCapableConnection streamConn = (IStreamCapableConnection) conn;
			SimpleConnectionBWConfig bwConfig = new SimpleConnectionBWConfig();
			bwConfig.getChannelBandwidth()[IBandwidthConfigure.OVERALL_CHANNEL] =
				1024*1024;
			bwConfig.getChannelInitialBurst()[IBandwidthConfigure.OVERALL_CHANNEL] =
				128*1024;
			streamConn.setBandwidthConfigure(bwConfig);
		}
		
		return super.appConnect(conn, params);
	}
	
	public void appDisconnect(IConnection conn){
		log.info("deskShare appDisconnect");
		if (appScope == conn.getScope() && serverStream != null){
			serverStream.close();
		}
		super.appDisconnect(conn);
	}
	
	public List<String> getStreams(){
		IConnection conn = Red5.getConnectionLocal();
		return getBroadcastStreamNames(conn.getScope());
	}
	
}
