package org.bigbluebutton.conference

import net.jcip.annotations.ThreadSafe
/**
 * Contains information for a Participant. Encapsulates status and the
 * only way to change/add status is through setStatus;
 */
@ThreadSafe
	private final Long userid
	private final String name
	private final String role = "VIEWER"
	private final Map status
	private final Map<String, Object> unmodifiableStatus
	
	public Participant(Long userid, String name, String role, Map<String, Object> status) {
		this.userid = userid
		this.name = name
		this.role = role 
		this.status = new ConcurrentHashMap<String, Object>(status)
		unmodifiableStatus = Collections.unmodifiableMap(status)
	}
	
	public String getName() {
		return name
	}
	
	public Long getUserid() {
		return userid
	}
	
	public String getRole() {
		return role
	}
	
	/**
	 * Returns that status for this participant. However, the status cannot
	 * be modified. To do that, setStatus(...) must be used.
	 */
	public Map getStatus() {
		return unmodifiableStatus
	}
	
	public void setStatus(String statusName, Object value) {
		// Should we sychronize?
		synchronized (this) {
			status.put(statusName, value)
			/**
			 * Update unmodifiableStatus as it does not get synched with status.
			 * Not sure it it should auto-syc, so just sync it. 
			 * Not sure if this is the right way to do it (ralam 2/26/2009).
			 */
			unmodifiableStatus = Collections.unmodifiableMap(status)
		}
	}
	
	public void removeStatus(String statusName) {
		// Should we sychronize?
		synchronized (this) {
			status.remove(statusName)
			/**
			 * Update unmodifiableStatus as it does not get synched with status.
			 * Not sure it it should auto-syc, so just sync it. 
			 * Not sure if this is the right way to do it (ralam 2/26/2009).
			 */
			unmodifiableStatus = Collections.unmodifiableMap(status)
		}
	}
	
	public Map toMap() {
		Map m = new HashMap()
		m.put("userid", userid)
		m.put("name", name)
		m.put("role", role)
		/**
		 * Create a copy of the status instead of returning the
		 * unmodifiableMap. This way callers can still manipulate it
		 * for their own purpose but our copy still remains unmodified.
		 */
		m.put("status", new HashMap(unmodifiableStatus))
		return m
	}
}