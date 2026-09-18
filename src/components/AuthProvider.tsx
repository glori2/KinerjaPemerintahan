'use client';

import React, { createContext, useContext, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { useRouter } from 'next/navigation';

interface AuthContextType {
  user: any;
  profile: any;
  assignment: any;
  employee: any;
  loading: boolean;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  profile: null,
  assignment: null,
  employee: null,
  loading: true,
  signOut: async () => {},
});

export const useAuth = () => useContext(AuthContext);

export default function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<any>(null);
  const [profile, setProfile] = useState<any>(null);
  const [assignment, setAssignment] = useState<any>(null);
  const [employee, setEmployee] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const fetchSession = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user) {
        await loadUserData(session.user);
      } else {
        setLoading(false);
      }
    };

    fetchSession();

    const { data: authListener } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (session?.user) {
        await loadUserData(session.user);
      } else {
        setUser(null);
        setProfile(null);
        setAssignment(null);
        setEmployee(null);
        setLoading(false);
        router.push('/login');
      }
    });

    return () => {
      authListener.subscription.unsubscribe();
    };
  }, []);

  const loadUserData = async (authUser: any) => {
    setUser(authUser);
    try {
      // Fetch profile
      const { data: prof } = await supabase.from('profiles').select('*').eq('id', authUser.id).single();
      setProfile(prof);

      // Fetch employee
      const { data: emp } = await supabase.from('employees').select('*').eq('profile_id', authUser.id).single();
      setEmployee(emp);

      if (emp) {
        // Fetch active assignment
        const { data: assign } = await supabase
          .from('employee_position_assignments')
          .select('*, position:positions(name, is_pamong_tukin_eligible)')
          .eq('employee_id', emp.id)
          .eq('status', 'active')
          .single();
        setAssignment(assign);
      }
    } catch (err) {
      console.error('Error loading user data:', err);
    } finally {
      setLoading(false);
    }
  };

  const signOut = async () => {
    await supabase.auth.signOut();
  };

  return (
    <AuthContext.Provider value={{ user, profile, assignment, employee, loading, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}
