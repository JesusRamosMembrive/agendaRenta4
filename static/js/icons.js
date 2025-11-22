/**
 * Lucide Icons Integration
 * Helper functions for rendering SVG icons throughout the application
 *
 * Usage:
 * - Include lucide.min.js before this file
 * - Call lucide.createIcons() after DOM is ready
 * - Use getIcon() or renderIcon() for dynamic icon generation
 */

/**
 * Get an icon element by name
 * @param {string} name - Lucide icon name (e.g., 'bell', 'check-circle')
 * @param {string} className - Additional CSS classes
 * @returns {HTMLElement} Icon element
 */
function getIcon(name, className = '') {
  const i = document.createElement('i');
  i.setAttribute('data-lucide', name);
  if (className) {
    i.className = className;
  }
  return i;
}

/**
 * Render an icon as HTML string
 * @param {string} name - Lucide icon name
 * @param {string} className - Additional CSS classes
 * @returns {string} HTML string for icon
 */
function renderIcon(name, className = '') {
  return `<i data-lucide="${name}" class="${className}"></i>`;
}

/**
 * Replace emoji with Lucide icon
 * @param {HTMLElement} element - Element containing emoji
 * @param {string} iconName - Lucide icon name to replace with
 * @param {string} className - Additional CSS classes
 */
function replaceEmojiWithIcon(element, iconName, className = 'icon') {
  element.innerHTML = renderIcon(iconName, className);
  lucide.createIcons();
}

/**
 * Initialize all icons on the page
 * Call this after DOM is ready or after dynamically adding icons
 */
function initIcons() {
  if (typeof lucide !== 'undefined') {
    lucide.createIcons();
  } else {
    console.warn('Lucide library not loaded. Icons will not render.');
  }
}

/**
 * Common icon mappings for the application
 */
const IconMap = {
  // Status icons
  success: 'check-circle',
  error: 'x-circle',
  warning: 'alert-triangle',
  info: 'info',
  pending: 'clock',

  // Task management icons
  task: 'check-square',
  calendar: 'calendar',
  alert: 'bell',
  notification: 'bell-ring',

  // Actions
  add: 'plus',
  edit: 'edit-3',
  delete: 'trash-2',
  save: 'save',
  cancel: 'x',
  search: 'search',
  filter: 'filter',
  refresh: 'refresh-cw',

  // Navigation
  home: 'home',
  settings: 'settings',
  user: 'user',
  logout: 'log-out',
  menu: 'menu',

  // Quality checks
  crawler: 'globe',
  link: 'link',
  image: 'image',
  code: 'code',

  // UI elements
  chevronDown: 'chevron-down',
  chevronUp: 'chevron-up',
  chevronRight: 'chevron-right',
  chevronLeft: 'chevron-left',
  eye: 'eye',
  eyeOff: 'eye-off',

  // Priority & status
  priority: 'star',
  completed: 'check-circle-2',
  inProgress: 'loader',
  blocked: 'octagon'
};

/**
 * Get icon by semantic name
 * @param {string} semanticName - Semantic icon name from IconMap
 * @param {string} className - Additional CSS classes
 * @returns {HTMLElement} Icon element
 */
function getSemanticIcon(semanticName, className = '') {
  const iconName = IconMap[semanticName] || semanticName;
  return getIcon(iconName, className);
}

/**
 * Auto-initialize icons when DOM is ready
 */
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initIcons);
} else {
  initIcons();
}
