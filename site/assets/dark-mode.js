/**
 * Dark Mode Toggle JavaScript for Minima Jekyll Theme
 * Handles theme switching and persistence
 */

(function() {
  'use strict';

  // Theme constants
  const THEME_KEY = 'theme-preference';
  const LIGHT_THEME = 'light';
  const DARK_THEME = 'dark';
  
  // DOM elements
  let toggleButton = null;
  let themeIcon = null;
  let themeText = null;

  /**
   * Get the current theme from localStorage or system preference
   */
  function getCurrentTheme() {
    const stored = localStorage.getItem(THEME_KEY);
    if (stored) {
      return stored;
    }
    
    // Check system preference
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return DARK_THEME;
    }
    
    return LIGHT_THEME;
  }

  /**
   * Apply theme to the document
   */
  function applyTheme(theme) {
    const html = document.documentElement;
    
    if (theme === DARK_THEME) {
      html.setAttribute('data-theme', 'dark');
    } else {
      html.removeAttribute('data-theme');
    }
    
    // Update button text and icon
    updateToggleButton(theme);
    
    // Store preference
    localStorage.setItem(THEME_KEY, theme);
  }

  /**
   * Update toggle button appearance
   */
  function updateToggleButton(theme) {
    if (!toggleButton || !themeIcon || !themeText) return;
    
    if (theme === DARK_THEME) {
      themeIcon.innerHTML = '☀️'; // Sun icon for switching to light
      themeText.textContent = 'Light';
      toggleButton.setAttribute('aria-label', 'Switch to light mode');
      toggleButton.setAttribute('title', 'Switch to light mode');
    } else {
      themeIcon.innerHTML = '🌙'; // Moon icon for switching to dark
      themeText.textContent = 'Dark';
      toggleButton.setAttribute('aria-label', 'Switch to dark mode');
      toggleButton.setAttribute('title', 'Switch to dark mode');
    }
  }

  /**
   * Toggle between light and dark themes
   */
  function toggleTheme() {
    const currentTheme = getCurrentTheme();
    const newTheme = currentTheme === DARK_THEME ? LIGHT_THEME : DARK_THEME;
    applyTheme(newTheme);
    
    // Add a subtle animation feedback
    if (toggleButton) {
      toggleButton.style.transform = 'scale(0.95)';
      setTimeout(() => {
        toggleButton.style.transform = '';
      }, 150);
    }
  }

  /**
   * Create and insert the toggle button
   */
  function createToggleButton() {
    // Create button element
    toggleButton = document.createElement('button');
    toggleButton.className = 'dark-mode-toggle';
    toggleButton.setAttribute('type', 'button');
    
    // Create icon span
    themeIcon = document.createElement('span');
    themeIcon.className = 'theme-icon';
    themeIcon.setAttribute('aria-hidden', 'true');
    
    // Create text span
    themeText = document.createElement('span');
    themeText.className = 'theme-text';
    
    // Assemble button
    toggleButton.appendChild(themeIcon);
    toggleButton.appendChild(themeText);
    
    // Add event listener
    toggleButton.addEventListener('click', toggleTheme);
    
    // Insert into DOM
    document.body.appendChild(toggleButton);
    
    // Initialize button appearance
    updateToggleButton(getCurrentTheme());
  }

  /**
   * Listen for system theme changes
   */
  function setupSystemThemeListener() {
    if (window.matchMedia) {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
      
      mediaQuery.addEventListener('change', function(e) {
        // Only apply system theme if user hasn't set a preference
        if (!localStorage.getItem(THEME_KEY)) {
          applyTheme(e.matches ? DARK_THEME : LIGHT_THEME);
        }
      });
    }
  }

  /**
   * Initialize the dark mode functionality
   */
  function init() {
    // Apply initial theme immediately to prevent flash
    applyTheme(getCurrentTheme());
    
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', function() {
        createToggleButton();
        setupSystemThemeListener();
      });
    } else {
      createToggleButton();
      setupSystemThemeListener();
    }
  }

  /**
   * Expose public API
   */
  window.ThemeToggle = {
    toggle: toggleTheme,
    setTheme: applyTheme,
    getCurrentTheme: getCurrentTheme,
    LIGHT_THEME: LIGHT_THEME,
    DARK_THEME: DARK_THEME
  };

  // Initialize immediately
  init();

})();

// Add keyboard shortcut support (Ctrl/Cmd + Shift + D)
document.addEventListener('keydown', function(e) {
  if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key.toLowerCase() === 'd') {
    e.preventDefault();
    if (window.ThemeToggle) {
      window.ThemeToggle.toggle();
    }
  }
});

// Add accessibility improvements
document.addEventListener('DOMContentLoaded', function() {
  // Announce theme changes to screen readers
  const announcer = document.createElement('div');
  announcer.setAttribute('aria-live', 'polite');
  announcer.setAttribute('aria-atomic', 'true');
  announcer.style.position = 'absolute';
  announcer.style.left = '-10000px';
  announcer.style.width = '1px';
  announcer.style.height = '1px';
  announcer.style.overflow = 'hidden';
  document.body.appendChild(announcer);

  // Listen for theme changes and announce them
  const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.type === 'attributes' && mutation.attributeName === 'data-theme') {
        const theme = document.documentElement.getAttribute('data-theme');
        announcer.textContent = theme === 'dark' ? 'Dark mode enabled' : 'Light mode enabled';
      }
    });
  });

  observer.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ['data-theme']
  });
});