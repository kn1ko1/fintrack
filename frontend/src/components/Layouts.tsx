// frontend/src/components/Layout.tsx

import React from 'react';
import { Outlet, Link } from 'react-router-dom';

const Layout = () => {
  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <div className="w-64 bg-indigo-800 text-white">
        <div className="p-6">
          <h1 className="text-2xl font-bold">FinTrack</h1>
        </div>
        <nav className="mt-6">
          <Link to="/" className="block py-2.5 px-4 hover:bg-indigo-700">Dashboard</Link>
          <Link to="/debts" className="block py-2.5 px-4 hover:bg-indigo-700">Debts</Link>
          <Link to="/expenses" className="block py-2.5 px-4 hover:bg-indigo-700">Expenses</Link>
          <Link to="/investments" className="block py-2.5 px-4 hover:bg-indigo-700">Investments</Link>
          <Link to="/companies" className="block py-2.5 px-4 hover:bg-indigo-700">Companies</Link>
          <Link to="/profile" className="block py-2.5 px-4 hover:bg-indigo-700">Profile</Link>
        </nav>
      </div>
      
      {/* Main content */}
      <div className="flex-1 overflow-auto">
        <header className="bg-white shadow">
          <div className="max-w-7xl mx-auto py-4 px-4 sm:px-6 lg:px-8">
            <h1 className="text-lg font-semibold text-gray-900">
              Financial Management
            </h1>
          </div>
        </header>
        <main>
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default Layout;