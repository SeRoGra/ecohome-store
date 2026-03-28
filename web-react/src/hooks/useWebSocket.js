import { useState, useEffect, useRef, useCallback } from 'react';
const WS_URL = process.env.REACT_APP_WS_URL || 'ws://localhost:8080';

export function useWebSocket(token) {
  const [messages,  setMessages]  = useState([]);
  const [connected, setConnected] = useState(false);
  const [error,     setError]     = useState(null);
  const wsRef        = useRef(null);
  const reconnectRef = useRef(null);
  const mountedRef   = useRef(true);

  const connect = useCallback(() => {
    if (!token || !mountedRef.current) return;
    try {
      const ws = new WebSocket(`${WS_URL}/ws/chat?token=${encodeURIComponent(token)}`);
      wsRef.current = ws;
      ws.onopen    = () => { if (!mountedRef.current) return; setConnected(true); setError(null); setMessages([]); };
      ws.onmessage = ({ data }) => {
        if (!mountedRef.current) return;
        try {
          const msg = JSON.parse(data);
          setMessages(prev => msg.id && prev.some(m => m.id === msg.id) ? prev : [...prev, msg]);
        } catch {}
      };
      ws.onclose = ({ code }) => {
        if (!mountedRef.current) return;
        setConnected(false);
        if (code !== 1000 && mountedRef.current)
          reconnectRef.current = setTimeout(connect, 3000);
      };
      ws.onerror = () => { if (!mountedRef.current) return; setError('Error de conexion WebSocket'); setConnected(false); };
    } catch { setError('No se pudo crear conexion WebSocket'); }
  }, [token]);

  useEffect(() => {
    mountedRef.current = true;
    connect();
    return () => {
      mountedRef.current = false;
      clearTimeout(reconnectRef.current);
      wsRef.current?.close(1000, 'unmount');
    };
  }, [connect]);

  const sendMessage = useCallback((text) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({ text }));
      return true;
    }
    return false;
  }, []);

  return { messages, connected, error, sendMessage };
}
