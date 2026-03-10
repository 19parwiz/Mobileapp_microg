import subprocess
import shutil
import sys


class RTSPPusher:
    def __init__(self, rtsp_url: str, width: int, height: int, fps: int = 25, bitrate: str = "2500k"):
        self.rtsp_url = rtsp_url
        self.width = int(width)
        self.height = int(height)
        self.fps = int(fps)
        self.bitrate = str(bitrate)
        self.proc = None

    def _print_ffmpeg_stderr_tail(self):
        if not self.proc or not self.proc.stderr:
            return
        try:
            err_text = self.proc.stderr.read()
            if err_text:
                print(f"[RTSP] ffmpeg stderr:\n{err_text.strip()}", file=sys.stderr)
        except Exception:
            pass

    def start(self):
        if not shutil.which("ffmpeg"):
            print("[RTSP] ERROR: ffmpeg not found in PATH. Install FFmpeg.", file=sys.stderr)
            return False

        cmd = [
            "ffmpeg",
            "-loglevel", "error",
            "-re",
            "-f", "rawvideo",
            "-pix_fmt", "bgr24",
            "-s", f"{self.width}x{self.height}",
            "-r", str(self.fps),
            "-i", "-",
            "-an",
            "-c:v", "libx264",
            "-preset", "veryfast",
            "-tune", "zerolatency",
            "-pix_fmt", "yuv420p",
            "-b:v", self.bitrate,
            "-g", str(max(self.fps, 1) * 2),
            "-rtsp_transport", "tcp",
            "-f", "rtsp",
            self.rtsp_url,
        ]

        try:
            self.proc = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
            print(
                f"[RTSP] started -> {self.rtsp_url} "
                f"({self.width}x{self.height}@{self.fps}fps, {self.bitrate})"
            )
            return True
        except Exception as e:
            print(f"[RTSP] ERROR: failed to start ffmpeg: {e}", file=sys.stderr)
            self.proc = None
            return False

    def push(self, frame_bgr):
        if not self.proc or not self.proc.stdin:
            return

        # If ffmpeg crashed/quit, avoid writing and surface stderr details.
        if self.proc.poll() is not None:
            print(f"[RTSP] ERROR: ffmpeg exited with code {self.proc.returncode}", file=sys.stderr)
            self._print_ffmpeg_stderr_tail()
            self.stop()
            return

        try:
            self.proc.stdin.write(frame_bgr.tobytes())
        except BrokenPipeError:
            print("[RTSP] WARN: ffmpeg pipe closed (BrokenPipe). Is server reachable?")
            self._print_ffmpeg_stderr_tail()
            self.stop()

    def stop(self):
        if self.proc:
            try:
                if self.proc.stdin:
                    self.proc.stdin.close()
            except Exception:
                pass
            try:
                self.proc.terminate()
                self.proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                try:
                    self.proc.kill()
                    self.proc.wait(timeout=2)
                except Exception:
                    pass
            except Exception:
                pass
            finally:
                self.proc = None
            print("[RTSP] stopped")
