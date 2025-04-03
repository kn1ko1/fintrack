// frontend/src/context/AuthContext.tsx

import React, { createContext, useState, useContext, useEffect } from 'react';

interface AuthContextType {
  isAuthenticated: boolean;
  user: any | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [user, setUser] = useState<any | null>(null);
  
  // Check if user is logged in on initial load
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      // For now, just consider having a token as being authenticated
      // Later, we'll add token verification
      setIsAuthenticated(true);
      // TODO: Fetch user data
    }
  }, []);
  
  const login = async (email: string, password: string) => {
    // TODO: Implement actual API call
    console.log('Logging in with:', email, password);
    
    // Mock successful login
    const mockToken = 'mock_token_123';
    const mockUser = { email, name: 'Test User' };
    
    localStorage.setItem('token', mockToken);
    setUser(mockUser);
    setIsAuthenticated(true);
  };
  
  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
    setIsAuthenticated(false);
  };
  
  return (
    <AuthContext.Provider value={{ isAuthenticated, user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};