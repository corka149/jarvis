export class WebSocketClient {
  /**
   * @param {string} url - The WebSocket connection URL.
   * @param {Object} options - Configuration options for backoff.
   */
  constructor(url, options = {}) {
    this.url = url;
    this.ws = null;

    // Exponential Backoff Configuration
    this.maxRetries = options.maxRetries || 10;
    this.retryCount = 0;
    this.baseDelay = options.baseDelay || 1000; // Starts at 1 second
    this.maxDelay = options.maxDelay || 30000;  // Caps out at 30 seconds

    // Event Hooks
    this.hooks = {
      onConnect: [],
      onDisconnect: [],
      onMessage: []
    };

    // Initialize the first connection
    this.connect();
  }

  // --- Core Connection Logic ---

  connect() {
    this.ws = new WebSocket(this.url);

    this.ws.onopen = (event) => {
      // Reset retry count on a successful connection
      this.retryCount = 0; 
      this.triggerHook('onConnect', event);
    };

    this.ws.onmessage = (event) => {
      this.triggerHook('onMessage', event.data);
    };

    this.ws.onclose = (event) => {
      this.triggerHook('onDisconnect', event);
      this.reconnect();
    };

    this.ws.onerror = (error) => {
      console.error("WebSocketClient Error:", error);
      // Note: onclose typically fires immediately after onerror, 
      // so we let the onclose handler trigger the reconnect.
    };
  }

  reconnect() {
    if (this.retryCount >= this.maxRetries) {
      console.warn("WebSocketClient: Maximum reconnection attempts reached.");
      return;
    }

    // Calculate delay: baseDelay * 2^retryCount, capped at maxDelay
    const delay = Math.min(this.baseDelay * Math.pow(2, this.retryCount), this.maxDelay);

    console.log(`WebSocketClient: Reconnecting in ${delay / 1000}s... (Attempt ${this.retryCount + 1} of ${this.maxRetries})`);

    setTimeout(() => {
      this.retryCount++;
      this.connect();
    }, delay);
  }

  // --- Public Methods ---

  /**
   * Sends a message through the WebSocket.
   * @param {string|Object} message - The data to send. Objects are auto-stringified.
   */
  send(message) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      const data = typeof message === 'object' ? JSON.stringify(message) : message;
      this.ws.send(data);
    } else {
      console.warn("WebSocketClient: Cannot send message. Connection is not open.");
    }
  }

  /**
   * Registers a callback hook for a specific event.
   * @param {string} event - 'onConnect', 'onDisconnect', or 'onMessage'
   * @param {Function} callback - The function to execute
   */
  on(event, callback) {
    if (this.hooks[event]) {
      this.hooks[event].push(callback);
    } else {
      console.error(`WebSocketClient: Unknown event '${event}'. Valid events are: onConnect, onDisconnect, onMessage.`);
    }
  }

  /**
   * Gracefully closes the connection without triggering a reconnect.
   */
  close() {
    if (this.ws) {
      // Override onclose so we don't accidentally trigger the reconnect logic
      this.ws.onclose = (event) => this.triggerHook('onDisconnect', event);
      this.ws.close();
    }
  }

  // --- Internal Utilities ---

  triggerHook(event, data) {
    if (this.hooks[event]) {
      this.hooks[event].forEach(callback => callback(data));
    }
  }
}