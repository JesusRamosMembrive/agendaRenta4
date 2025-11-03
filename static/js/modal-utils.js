/**
 * Modal Utilities
 *
 * Reusable modal management for quality check execution.
 * Handles opening, closing, progress tracking, and API calls.
 */

class QualityCheckModal {
    /**
     * Create a QualityCheckModal instance
     * @param {string} modalId - ID of the modal element
     * @param {string} progressContainerId - ID of the progress container element
     * @param {string} progressBarId - ID of the progress bar element
     * @param {string} progressTextId - ID of the progress text element
     */
    constructor(modalId, progressContainerId, progressBarId, progressTextId) {
        this.modal = document.getElementById(modalId);
        this.progressContainer = document.getElementById(progressContainerId);
        this.progressBar = document.getElementById(progressBarId);
        this.progressText = document.getElementById(progressTextId);
        this.progressInterval = null;
    }

    /**
     * Open the modal
     */
    open() {
        if (this.modal) {
            this.modal.style.display = 'flex';
        }
    }

    /**
     * Close the modal and reset its state
     */
    close() {
        if (this.modal) {
            this.modal.style.display = 'none';
        }

        // Reset progress
        this.hideProgress();
        this.stopProgressAnimation();
    }

    /**
     * Show progress container and start indeterminate animation
     * @param {string} initialMessage - Initial progress message to display
     */
    showProgress(initialMessage = 'Iniciando...') {
        if (this.progressContainer) {
            this.progressContainer.style.display = 'block';
        }
        if (this.progressText) {
            this.progressText.textContent = initialMessage;
        }
        if (this.progressBar) {
            this.progressBar.style.width = '0%';
        }
    }

    /**
     * Hide progress container
     */
    hideProgress() {
        if (this.progressContainer) {
            this.progressContainer.style.display = 'none';
        }
        if (this.progressBar) {
            this.progressBar.style.width = '0%';
        }
    }

    /**
     * Update progress message
     * @param {string} message - Message to display
     */
    updateProgress(message) {
        if (this.progressText) {
            this.progressText.textContent = message;
        }
    }

    /**
     * Set progress bar to specific percentage
     * @param {number} percent - Percentage (0-100)
     */
    setProgress(percent) {
        if (this.progressBar) {
            this.progressBar.style.width = `${percent}%`;
        }
    }

    /**
     * Start indeterminate progress animation
     */
    startProgressAnimation() {
        this.stopProgressAnimation(); // Clear any existing animation

        let progress = 0;
        this.progressInterval = setInterval(() => {
            progress = (progress + 5) % 100;
            if (this.progressBar) {
                this.progressBar.style.width = progress + '%';
            }
        }, 200);
    }

    /**
     * Stop progress animation
     */
    stopProgressAnimation() {
        if (this.progressInterval) {
            clearInterval(this.progressInterval);
            this.progressInterval = null;
        }
    }

    /**
     * Mark progress as complete
     * @param {string} message - Completion message
     */
    completeProgress(message = '✅ Completado') {
        this.stopProgressAnimation();
        this.setProgress(100);
        this.updateProgress(message);
    }

    /**
     * Mark progress as error
     * @param {string} message - Error message
     */
    errorProgress(message = '❌ Error') {
        this.stopProgressAnimation();
        this.updateProgress(message);
    }

    /**
     * Execute quality checks via API
     * @param {Array<string>} checkTypes - Types of checks to run
     * @param {string} scope - Scope of URLs ('priority' or 'all')
     * @param {string} progressMessage - Message to show during execution
     * @returns {Promise<object>} API response data
     */
    async executeChecks(checkTypes, scope, progressMessage = 'Ejecutando checks...') {
        this.showProgress(progressMessage);
        this.setProgress(20);
        this.startProgressAnimation();

        try {
            const response = await fetch('/crawler/quality/run', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    check_types: checkTypes,
                    scope: scope
                })
            });

            this.stopProgressAnimation();
            this.setProgress(90);
            this.updateProgress('Procesando resultados...');

            const data = await response.json();
            return data;

        } catch (error) {
            console.error('Error executing checks:', error);
            this.errorProgress('❌ Error de conexión');
            throw error;
        }
    }
}

/**
 * API Response Parser Utilities
 */
const APIUtils = {
    /**
     * Parse check results from API response
     * @param {object} data - API response data
     * @param {string} checkType - Type of check to extract
     * @returns {object} Parsed check result with status, stats, and message
     */
    parseCheckResult(data, checkType) {
        const checks = data.results?.checks || [];
        const check = checks.find(c => c.check_type === checkType) || checks[0];

        return {
            status: check?.status || 'unknown',
            stats: check?.stats || {},
            message: check?.message || ''
        };
    },

    /**
     * Format check result for display
     * @param {object} checkResult - Parsed check result from parseCheckResult
     * @param {string} checkType - Type of check
     * @returns {string} Formatted message string
     */
    formatCheckResult(checkResult, checkType) {
        let message = '';

        if (checkType === 'broken_links') {
            message += `Estado: ${checkResult.status}\n`;
            message += `URLs validadas: ${checkResult.stats.validated || 0}\n`;
            message += `Enlaces rotos: ${checkResult.stats.broken || 0}\n`;
        } else if (checkType === 'image_quality') {
            message += `Estado: ${checkResult.status}\n`;
            message += `URLs procesadas: ${checkResult.stats.processed || 0}\n`;
            message += `Guardadas en BD: ${checkResult.stats.successful || 0}\n`;
        }

        if (checkResult.message) {
            message += `\nDetalles: ${checkResult.message}`;
        }

        return message;
    }
};

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { QualityCheckModal, APIUtils };
}
