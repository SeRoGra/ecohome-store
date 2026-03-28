import { useState, useEffect, useRef, useCallback } from 'react';
import { io } from 'socket.io-client';

const SERVER_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080';

export function useSocket(token) {
  const [messages,  setMessages]  = useState([]);
  const [connected, setConnected] = useState(false);
  const [error,     setError]     = useState(null);
  const socketRef = useRef(null);

  useEffect(() => {
    if (!token) return;

    const socket = io(SERVER_URL, {
      auth: { token },
    });
    socketRef.current = socket;

    socket.on('connect', () => {
      setConnected(true);
      setError(null);
    });

    // Historial: ultimos 10 mensajes al conectar
    socket.on('messages', (history) => {
      setMessages(history);
    });

    // Mensajes en vivo (broadcast)
    socket.on('new-message', (msg) => {
      setMessages(prev =>
        msg.id && prev.some(m => m.id === msg.id) ? prev : [...prev, msg]
      );
    });

    socket.on('disconnect', () => {
      setConnected(false);
    });

    socket.on('connect_error', (err) => {
      setError('Error de conexion: ' + err.message);
      setConnected(false);
    });

    return () => {
      socket.disconnect();
    };
  }, [token]);

  const sendMessage = useCallback((text) => {
    if (socketRef.current?.connected) {
      socketRef.current.emit('new-message', { text });
      return true;
    }
    return false;
  }, []);

  return { messages, connected, error, sendMessage };
}
