import { useState, useCallback } from 'react';
import { login as apiLogin, register as apiRegister } from '../api/chatApi';

export function useAuth() {
  const [token,   setToken]   = useState(() => localStorage.getItem('token'));
  const [username,setUsername]= useState(() => localStorage.getItem('username'));
  const [role,    setRole]    = useState(() => localStorage.getItem('role'));
  const [loading, setLoading] = useState(false);
  const [error,   setError]   = useState(null);

  const login = useCallback(async (user, pass) => {
    setLoading(true); setError(null);
    try {
      const { data } = await apiLogin(user, pass);
      localStorage.setItem('token', data.token);
      localStorage.setItem('username', data.username);
      localStorage.setItem('role', data.role);
      setToken(data.token); setUsername(data.username); setRole(data.role);
      return true;
    } catch (err) {
      setError(err.response?.data?.message || 'Credenciales invalidas');
      return false;
    } finally { setLoading(false); }
  }, []);

  const register = useCallback(async (user, email, pass, rol) => {
    setLoading(true); setError(null);
    try { await apiRegister(user, email, pass, rol); return true; }
    catch (err) { setError(err.response?.data?.message || 'Error en registro'); return false; }
    finally { setLoading(false); }
  }, []);

  const logout = useCallback(() => {
    localStorage.clear();
    setToken(null); setUsername(null); setRole(null);
  }, []);

  return { token, username, role, loading, error, login, register, logout };
}
