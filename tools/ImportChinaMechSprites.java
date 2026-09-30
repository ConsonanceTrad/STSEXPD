import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import javax.imageio.ImageIO;

/**
 * Imports the original SPS-PD 0.9.9 ChinaMech and JumperDancer icons without resampling.
 * 0.9.9 items.png is a 20-column sheet: ChinaMech index 112 at (192,80), JUMPER_DANCER 720 at (0,576).
 * Target cells are the two free 16x16 slots at 0-based grid (7,60) and (8,60) = pixels (112,960) and (128,960).
 */
public final class ImportChinaMechSprites {

	public static void main(String[] args) throws IOException {
		if (args.length != 2) throw new IllegalArgumentException("usage: source-items.png target-items.png");
		BufferedImage source = requireImage(new File(args[0]));
		File targetFile = new File(args[1]);
		BufferedImage target = requireImage(targetFile);
		if (source.getWidth() != 320 || source.getHeight() != 592) throw new IOException("unexpected 0.9.9 source sheet size");
		if (target.getWidth() != 256 || target.getHeight() != 992) throw new IOException("unexpected target sheet size");

		BufferedImage output = new BufferedImage(target.getWidth(), target.getHeight(), BufferedImage.TYPE_INT_ARGB);
		for (int y = 0; y < target.getHeight(); y++) {
			for (int x = 0; x < target.getWidth(); x++) output.setRGB(x, y, target.getRGB(x, y));
		}
		copyIcon(source, 192, 80, output, 112, 960);
		copyIcon(source, 0, 576, output, 128, 960);

		File temp = new File(targetFile.getParentFile(), targetFile.getName() + ".spsgift.tmp");
		if (!ImageIO.write(output, "png", temp)) throw new IOException("PNG writer unavailable");
		BufferedImage written = requireImage(temp);
		verifyIcon(written, 112, 960, source, 192, 80);
		verifyIcon(written, 128, 960, source, 0, 576);
		for (int y = 0; y < target.getHeight(); y++) {
			for (int x = 0; x < target.getWidth(); x++) {
				boolean inside = (x >= 112 && x < 144 && y >= 960 && y < 976);
				if (!inside && written.getRGB(x, y) != target.getRGB(x, y)) {
					throw new IOException("unexpected pixel change at " + x + "," + y);
				}
			}
		}
		Files.move(temp.toPath(), targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
		System.out.println("ChinaMech  icon sha256 " + iconHash(written, 112, 960));
		System.out.println("JumperDanc icon sha256 " + iconHash(written, 128, 960));
	}

	private static void copyIcon(BufferedImage source, int sx, int sy, BufferedImage output, int dx, int dy) {
		for (int y = 0; y < 16; y++) {
			for (int x = 0; x < 16; x++) output.setRGB(dx + x, dy + y, source.getRGB(sx + x, sy + y));
		}
	}

	private static void verifyIcon(BufferedImage written, int dx, int dy, BufferedImage source, int sx, int sy) throws IOException {
		for (int y = 0; y < 16; y++) {
			for (int x = 0; x < 16; x++) {
				if (written.getRGB(dx + x, dy + y) != source.getRGB(sx + x, sy + y)) {
					throw new IOException("icon pixel mismatch at " + (dx + x) + "," + (dy + y));
				}
			}
		}
	}

	private static String iconHash(BufferedImage image, int left, int top) throws IOException {
		try {
			ByteBuffer pixels = ByteBuffer.allocate(16 * 16 * 4).order(ByteOrder.LITTLE_ENDIAN);
			for (int y = top; y < top + 16; y++) {
				for (int x = left; x < left + 16; x++) pixels.putInt(image.getRGB(x, y));
			}
			StringBuilder result = new StringBuilder(64);
			for (byte value : MessageDigest.getInstance("SHA-256").digest(pixels.array())) {
				result.append(String.format("%02X", value & 0xFF));
			}
			return result.toString();
		} catch (NoSuchAlgorithmException exception) {
			throw new IOException(exception);
		}
	}

	private static BufferedImage requireImage(File file) throws IOException {
		BufferedImage image = ImageIO.read(file);
		if (image == null) throw new IOException("not a readable image: " + file);
		return image;
	}

	private ImportChinaMechSprites() { }
}
