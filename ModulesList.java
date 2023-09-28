import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

public class ModulesList {
	public static void main(String[] args) {
		Set<String> exclusions = new HashSet<>();
		exclusions.addAll( Arrays.asList( args) );
		String commaSeparatedList = ModuleLayer.boot()
				.modules()
				.stream()
				.map( Module::getName )
				.filter( name -> ! exclusions.contains( name ) )
				.sorted()
				.collect( Collectors.joining( "," ) );
		System.out.println( commaSeparatedList );
	}
}
