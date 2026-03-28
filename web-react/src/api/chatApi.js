import axios from 'axios';
const api = axios.create({ baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8080' });
api.interceptors.request.use(cfg => {
  const t = localStorage.getItem('token');
  if (t) cfg.headers.Authorization = `Bearer ${t}`;
  return cfg;
});
export const login       = (username, password)              => api.post('/api/auth/login', { username, password });
export const register    = (username, email, password, role) => api.post('/api/auth/register', { username, email, password, role });
export const getHistory  = ()                                => api.get('/api/chat/history');
export const getProducts = ()                                => api.get('/api/products');
export const createProduct = (data)                          => api.post('/api/products', data);
export const getUserStats  = ()                              => api.get('/api/users/me/stats');
export default api;
