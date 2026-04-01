import { queryClient } from '@/core/config/queryClient';
import { QueryClientProvider } from '@tanstack/react-query';
import { useEffect, type ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

export default function Provider({ children }: Props) {
  useEffect(() => {
    const media = window.matchMedia('(prefers-color-scheme: dark)');

    const apply = (dark: boolean) => {
      document.documentElement.classList.toggle('dark', dark);
    };

    apply(media.matches);
    media.addEventListener('change', (e) => apply(e.matches));

    return () => {
      media.removeEventListener('change', (e) => apply(e.matches));
    };
  }, []);

  return (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
}
