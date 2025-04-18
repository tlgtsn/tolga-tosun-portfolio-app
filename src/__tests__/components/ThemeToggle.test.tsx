import { render, screen } from '@testing-library/react';
import { ThemeProvider } from 'next-themes';
import ThemeToggle from '@/app/components/ThemeToggle';

describe('ThemeToggle', () => {
  it('should render theme toggle button', () => {
    render(
      <ThemeProvider>
        <ThemeToggle />
      </ThemeProvider>
    );
    
    const toggleButton = screen.getByRole('button');
    expect(toggleButton).toBeInTheDocument();
  });

  it('should change theme when clicked', () => {
    render(
      <ThemeProvider>
        <ThemeToggle />
      </ThemeProvider>
    );
    
    const toggleButton = screen.getByRole('button');
    const initialTheme = document.documentElement.classList.contains('dark');
    
    toggleButton.click();
    const newTheme = document.documentElement.classList.contains('dark');
    
    expect(newTheme).not.toBe(initialTheme);
  });
}); 