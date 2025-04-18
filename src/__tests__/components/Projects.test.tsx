import { render, screen } from '@testing-library/react';
import Projects from '@/app/components/Projects';

const mockProjects = [
  {
    id: 1,
    title: 'E-ticaret Platformu',
    description: 'Modern React ve Next.js ile geliştirilmiş e-ticaret platformu',
    technologies: ['React', 'Next.js', 'TypeScript'],
    image: '/project1.jpg'
  },
  {
    id: 2,
    title: 'Yönetim Paneli',
    description: 'Admin dashboard with real-time analytics',
    technologies: ['React', 'Redux', 'Material-UI'],
    image: '/project2.jpg'
  }
];

describe('Projects', () => {
  it('should render all projects', () => {
    render(<Projects projects={mockProjects} />);
    const projectElements = screen.getAllByTestId('project-card');
    expect(projectElements).toHaveLength(mockProjects.length);
  });

  it('should display project titles correctly', () => {
    render(<Projects projects={mockProjects} />);
    mockProjects.forEach(project => {
      const title = screen.getByText(project.title);
      expect(title).toBeInTheDocument();
    });
  });

  it('should display project technologies', () => {
    render(<Projects projects={mockProjects} />);
    mockProjects.forEach(project => {
      project.technologies.forEach(tech => {
        const techElement = screen.getByText(tech);
        expect(techElement).toBeInTheDocument();
      });
    });
  });
}); 