use crossterm::{
    cursor::{Hide, MoveTo, Show},
    execute,
    terminal::{self, Clear, ClearType},
    style::Print,
};
use std::io::{self, Write};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

/// Tracks tokens per second and elapsed time for LLM output
#[derive(Clone)]
pub struct LlmMetrics {
    start_time: Instant,
    token_count: Arc<Mutex<usize>>,
    last_update: Arc<Mutex<Instant>>,
    terminal_size: Arc<Mutex<(u16, u16)>>,
}

impl LlmMetrics {
    /// Create a new metrics tracker
    pub fn new() -> io::Result<Self> {
        let (cols, rows) = terminal::size()?;
        Ok(Self {
            start_time: Instant::now(),
            token_count: Arc::new(Mutex::new(0)),
            last_update: Arc::new(Mutex::new(Instant::now())),
            terminal_size: Arc::new(Mutex::new((cols, rows))),
        })
    }

    /// Increment the token count (call this after each token/chunk is output)
    pub fn add_tokens(&self, count: usize) {
        if let Ok(mut token_count) = self.token_count.lock() {
            *token_count += count;
        }
    }

    /// Update terminal size (call periodically or on resize events)
    pub fn update_terminal_size(&self) -> io::Result<()> {
        let (cols, rows) = terminal::size()?;
        if let Ok(mut size) = self.terminal_size.lock() {
            *size = (cols, rows);
        }
        Ok(())
    }

    /// Display the metrics in the lower-right corner of the terminal
    pub fn display(&self) -> io::Result<()> {
        let now = Instant::now();
        
        // Throttle updates to every 100ms
        if let Ok(mut last_update) = self.last_update.lock() {
            if now.duration_since(*last_update) < Duration::from_millis(100) {
                return Ok(());
            }
            *last_update = now;
        }

        // Update terminal size
        self.update_terminal_size()?;

        let elapsed = now.duration_since(self.start_time);
        let token_count = self.token_count.lock().unwrap_or_else(|e| e.into_inner());
        let (cols, rows) = *self.terminal_size.lock().unwrap_or_else(|e| e.into_inner());

        // Calculate tokens per second
        let elapsed_secs = elapsed.as_secs_f64();
        let tps = if elapsed_secs > 0.0 {
            *token_count as f64 / elapsed_secs
        } else {
            0.0
        };

        // Format time as MM:SS
        let total_secs = elapsed.as_secs();
        let minutes = total_secs / 60;
        let seconds = total_secs % 60;
        let time_str = format!("{:02}:{:02}", minutes, seconds);

        // Format metrics strings
        let tps_str = format!("{:.1} tok/s", tps);
        
        // Calculate positions (lower-right corner)
        let tps_len = tps_str.len() as u16;
        let time_len = time_str.len() as u16;
        let max_len = tps_len.max(time_len);
        
        if cols > max_len && rows > 1 {
            let tps_col = cols.saturating_sub(tps_len + 1);
            let time_col = cols.saturating_sub(time_len + 1);
            let tps_row = rows.saturating_sub(2);
            let time_row = rows.saturating_sub(1);

            let mut stdout = io::stdout();
            
            // Save cursor, hide it, print metrics, restore cursor
            execute!(
                stdout,
                crossterm::cursor::SavePosition,
                Hide,
                MoveTo(tps_col, tps_row),
                Clear(ClearType::UntilNewLine),
                Print(&tps_str),
                MoveTo(time_col, time_row),
                Clear(ClearType::UntilNewLine),
                Print(&time_str),
                crossterm::cursor::RestorePosition,
                Show
            )?;
            
            stdout.flush()?;
        }

        Ok(())
    }

    /// Clear the metrics display
    pub fn clear(&self) -> io::Result<()> {
        let (cols, rows) = *self.terminal_size.lock().unwrap_or_else(|e| e.into_inner());
        
        if rows > 1 {
            let mut stdout = io::stdout();
            execute!(
                stdout,
                crossterm::cursor::SavePosition,
                MoveTo(0, rows.saturating_sub(2)),
                Clear(ClearType::UntilNewLine),
                MoveTo(0, rows.saturating_sub(1)),
                Clear(ClearType::UntilNewLine),
                crossterm::cursor::RestorePosition
            )?;
            stdout.flush()?;
        }

        Ok(())
    }

    /// Get the elapsed time
    pub fn elapsed(&self) -> Duration {
        Instant::now().duration_since(self.start_time)
    }

    /// Get current token count
    pub fn token_count(&self) -> usize {
        *self.token_count.lock().unwrap_or_else(|e| e.into_inner())
    }

    /// Get current tokens per second
    pub fn tokens_per_second(&self) -> f64 {
        let elapsed_secs = self.elapsed().as_secs_f64();
        if elapsed_secs > 0.0 {
            self.token_count() as f64 / elapsed_secs
        } else {
            0.0
        }
    }
}

impl Default for LlmMetrics {
    fn default() -> Self {
        Self::new().expect("Failed to initialize LlmMetrics")
    }
}

impl Drop for LlmMetrics {
    fn drop(&mut self) {
        // Clear metrics on drop
        let _ = self.clear();
    }
}

/// Helper to estimate token count from text
/// This is a rough approximation: ~4 characters per token on average
pub fn estimate_tokens(text: &str) -> usize {
    // Simple estimation: count words and punctuation
    let words = text.split_whitespace().count();
    let punctuation = text.chars().filter(|c| c.is_ascii_punctuation()).count();
    (words + punctuation).max(text.len() / 4)
}
