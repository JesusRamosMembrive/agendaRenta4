/**
 * Agenda Renta4 - JavaScript Principal
 * Funcionalidad de radios desmarcables y cálculo de status
 */

// ===========================================================================
// 1) Toggle de Radios con Desmarcado (funciona con input y label)
// ===========================================================================
(function() {
  function getInputFromTarget(target) {
    if (target instanceof HTMLInputElement) return target;
    if (target instanceof HTMLLabelElement) {
      return target.querySelector('input[type="radio"]');
    }
    return null;
  }

  function handlePointerDown(e) {
    const input = getInputFromTarget(e.target);
    if (!input) return;
    if (input.type !== 'radio') return;

    // Si ya estaba marcado, marcar flag para desmarcar en click
    if (input.checked) {
      input.dataset.toggleOff = 'true';
    } else {
      // Al pulsar otro radio del mismo grupo, limpiamos flags del grupo
      document.querySelectorAll('input[type="radio"][name="' + input.name + '"]')
        .forEach(el => { el.dataset.toggleOff = 'false'; });
    }
  }

  function handleClick(e) {
    const input = getInputFromTarget(e.target);
    if (!input) return;
    if (input.type !== 'radio') return;

    if (input.dataset.toggleOff === 'true') {
      // Evitar que quede marcado; forzar desmarque
      input.checked = false;
      input.dataset.toggleOff = 'false';
      e.preventDefault();
      e.stopPropagation();
    } else {
      // Limpia flags en su grupo
      document.querySelectorAll('input[type="radio"][name="' + input.name + '"]')
        .forEach(el => { if (el !== input) el.dataset.toggleOff = 'false'; });
    }

    // Después de cada clic, recalcular estado de la fila
    queueMicrotask(updateAllRows);
  }

  document.addEventListener('pointerdown', handlePointerDown, true);
  document.addEventListener('click', handleClick, true);
})();

// ===========================================================================
// 2) Cálculo de Status por Fila y Apertura de Observaciones
// ===========================================================================
function updateRow(row) {
  const radios = row.querySelectorAll('input[type="radio"]');
  let problems = 0, oks = 0;
  const groups = 8; // 8 tipos de tareas

  radios.forEach(r => {
    if (r.checked) {
      if (r.classList.contains('prob')) problems++;
      if (r.classList.contains('ok')) oks++;
    }
  });

  const statusCell = row.querySelector('td:last-child .status-dot');
  const detail = row.nextElementSibling;

  // Mostrar/ocultar fila de observaciones
  if (detail && detail.classList.contains('url-detail')) {
    if (problems > 0) {
      detail.classList.add('open');
    } else {
      detail.classList.remove('open');
    }
  }

  // Actualizar color del status dot
  statusCell.className = 'status-dot sd-neutral';

  if (problems === 0 && oks === groups) {
    // Todo OK (verde)
    statusCell.className = 'status-dot sd-green';
  } else if (problems > 4) {
    // Muchos problemas (rojo)
    statusCell.className = 'status-dot sd-red';
  } else if (problems > 0) {
    // Algunos problemas (naranja)
    statusCell.className = 'status-dot sd-orange';
  }
}

function updateAllRows() {
  document.querySelectorAll('tr.url-row').forEach(updateRow);
}

// Inicializar al cargar la página
document.addEventListener('DOMContentLoaded', updateAllRows);

// Recalcular en cambios
document.addEventListener('change', function(e) {
  if (e.target && e.target.matches('input[type="radio"]')) {
    const row = e.target.closest('tr.url-row');
    if (row) updateRow(row);
  }
});

// ===========================================================================
// 3) Guardar Tareas Automáticamente (AJAX)
// ===========================================================================
function saveTask(taskId, status, sectionUrl) {
  const row = document.querySelector(`tr[data-section-url="${sectionUrl}"]`);
  if (!row) return;

  // Obtener observaciones si hay problemas
  const detail = row.nextElementSibling;
  let observations = '';
  if (detail && detail.classList.contains('url-detail')) {
    const textarea = detail.querySelector('textarea.obs');
    if (textarea) {
      observations = textarea.value;
    }
  }

  // Enviar a backend via fetch
  fetch('/tasks/update', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      task_id: taskId,
      status: status,
      observations: observations
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      console.log('Tarea guardada:', taskId);
    } else {
      console.error('Error guardando tarea:', data.error);
    }
  })
  .catch(error => {
    console.error('Error de red:', error);
  });
}

// ===========================================================================
// 4) Debounce para Auto-Save de Observaciones
// ===========================================================================
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Auto-save de observaciones después de 1 segundo de inactividad
document.addEventListener('DOMContentLoaded', function() {
  const textareas = document.querySelectorAll('textarea.obs');

  textareas.forEach(textarea => {
    const debouncedSave = debounce(function() {
      const row = textarea.closest('tr.url-detail')?.previousElementSibling;
      if (!row) return;

      const sectionUrl = row.dataset.sectionUrl;
      const taskIds = row.dataset.taskIds ? JSON.parse(row.dataset.taskIds) : [];

      // Guardar observaciones para todas las tareas de esta URL que tengan problemas
      // (implementar según necesidad)
      console.log('Auto-saving observations for:', sectionUrl);
    }, 1000);

    textarea.addEventListener('input', debouncedSave);
  });
});

// ===========================================================================
// 5) Búsqueda de URLs (si se implementa)
// ===========================================================================
function setupSearch() {
  const searchInput = document.querySelector('.input[placeholder="Buscar…"]');
  if (!searchInput) return;

  searchInput.addEventListener('input', debounce(function(e) {
    const query = e.target.value.toLowerCase().trim();

    if (query.length === 0) {
      // Mostrar todas las filas
      document.querySelectorAll('tr.url-row').forEach(row => {
        row.style.display = '';
        const detail = row.nextElementSibling;
        if (detail && detail.classList.contains('url-detail')) {
          detail.style.display = detail.classList.contains('open') ? '' : 'none';
        }
      });
      return;
    }

    // Filtrar filas por URL
    document.querySelectorAll('tr.url-row').forEach(row => {
      const urlCell = row.querySelector('.url-col');
      if (!urlCell) return;

      const url = urlCell.textContent.toLowerCase();
      if (url.includes(query)) {
        row.style.display = '';
        const detail = row.nextElementSibling;
        if (detail && detail.classList.contains('url-detail')) {
          detail.style.display = detail.classList.contains('open') ? '' : 'none';
        }
      } else {
        row.style.display = 'none';
        const detail = row.nextElementSibling;
        if (detail && detail.classList.contains('url-detail')) {
          detail.style.display = 'none';
        }
      }
    });
  }, 300));
}

document.addEventListener('DOMContentLoaded', setupSearch);

// ===========================================================================
// 6) Toggle de Tema Claro/Oscuro
// ===========================================================================
(function() {
  const themeToggleBtn = document.getElementById('theme-toggle');
  const themeIcon = document.getElementById('theme-icon');
  const htmlElement = document.documentElement;

  // Cargar tema guardado o usar tema claro por defecto
  function loadTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    setTheme(savedTheme);
  }

  // Aplicar tema
  function setTheme(theme) {
    htmlElement.setAttribute('data-theme', theme);

    // Actualizar icono
    if (themeIcon) {
      themeIcon.textContent = theme === 'dark' ? '🌙' : '☀️';
    }

    // Guardar en localStorage
    localStorage.setItem('theme', theme);
  }

  // Toggle entre temas
  function toggleTheme() {
    const currentTheme = htmlElement.getAttribute('data-theme') || 'light';
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
  }

  // Event listener para el botón
  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', toggleTheme);
  }

  // Cargar tema al iniciar
  loadTheme();
})();